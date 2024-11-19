// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Main page of this program.
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:based_split_view/based_split_view.dart';
import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/public_widget/split_page_placeholder.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/page/xdu_planet/xdu_planet_page.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:restart_app/restart_app.dart';
import 'package:watermeter/page/homepage/homepage.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/repository/message_session.dart' as message;
import 'package:watermeter/repository/message_session.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class PageInformation {
  final int index;
  final String name;
  final IconData icon;
  final IconData iconChoice;

  PageInformation({
    required this.index,
    required this.name,
    required this.icon,
    required this.iconChoice,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasedSplitView(
      navigatorKey: splitViewKey,
      leftWidget: HomePageMaster(
        key: leftKey,
      ),
      rightPlaceholder: const SplitPagePlaceholder(),
    );
  }
}

class HomePageMaster extends StatefulWidget {
  const HomePageMaster({super.key});

  @override
  State<HomePageMaster> createState() => _HomePageMasterState();
}

class _HomePageMasterState extends State<HomePageMaster>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  static bool refreshAtStart = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      updateCurrentData();
    }
  }

  late StreamSubscription _intentSub;
  late PageController _controller;
  late PageView _pageView;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _pageView = PageView(
      controller: _controller,
      children: const [
        MainPage(),
        XDUPlanetPage(),
        SettingWindow(),
      ],
      onPageChanged: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );

    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid || Platform.isIOS) {
      // Listen to media sharing coming from outside the app while the app is in the memory.
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        _onData,
        onError: (error, stacktrace) {
          log.error("getIntentDataStream error.", error, stacktrace);
        },
      );
      // Get the media sharing coming from outside the app while the app is closed.
      ReceiveSharingIntent.instance.getInitialMedia().then(_onData).catchError(
        (err, stacktrace) {
          log.error("getIntentDataStream error.", err, stacktrace);
        },
      );
    }
  }

  void _loginAsync() async {
    updateCurrentData(); // load cache data
    showToast(
      context: context,
      msg: FlutterI18n.translate(
        context,
        "homepage.login_message",
      ),
    );

    try {
      await update(
        context: context,
        forceRetryLogin: true,
        sliderCaptcha: (String cookieStr) {
          return SliderCaptchaClientProvider(cookie: cookieStr).solve(context);
        },
      );
    } finally {
      if (loginState == IDSLoginState.success) {
        if (mounted) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              "homepage.successful_login_message",
            ),
          );
        }
      } else if (loginState == IDSLoginState.passwordWrong) {
        await preference.remove(preference.Preference.idsPassword);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(FlutterI18n.translate(
                context,
                "homepage.password_wrong_title",
              )),
              content: Text(FlutterI18n.translate(
                context,
                "homepage.password_wrong_content",
              )),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Restart.restartApp();
                  },
                  child: Text(FlutterI18n.translate(
                    context,
                    "confirm",
                  )),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showOfflineModeNotice();
                  },
                  child: Text(FlutterI18n.translate(
                    context,
                    "homepage.password_wrong_denial",
                  )),
                ),
              ],
            ),
          );
        });
      } else {
        _showOfflineModeNotice();
      }
    }
  }

  void _showUpdateNotice() {
    if (updateMessage.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
          context: context,
          builder: (context) => Obx(
            () => UpdateDialog(
              updateMessage: updateMessage.value!,
            ),
          ),
        );
      });
    }
  }

  Future<void> _onData(List<SharedMediaFile> value) async {
    log.info("Input data: ${value.first.path}");

    if (Uri.tryParse(value.first.path) == null) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          "homepage.input_partner_data.route_not_exist",
        ),
      );
      ReceiveSharingIntent.instance.reset();
      return;
    }
    log.info("Partner File Position: ${value.first.path}");

    final c = Get.find<ClassTableController>();
    if (c.state == ClassTableState.fetched) {
      File file =
          File("${supportPath.path}/${ClassTableFile.partnerClassName}");

      log.info(
        "Partner file exists: "
        "${file.existsSync()}",
      );

      if (file.existsSync()) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(FlutterI18n.translate(
              context,
              "confirm_title",
            )),
            content: Text(FlutterI18n.translate(
              context,
              "homepage.input_partner_data.confirm_content",
            )),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(FlutterI18n.translate(
                  context,
                  "cancel",
                )),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(FlutterI18n.translate(
                  context,
                  "confirm",
                )),
              )
            ],
          ),
        );
        if (context.mounted && confirm != true) {
          return;
        }
      }
      String source = "";
      try {
        if (Platform.isAndroid && value.first.path.startsWith("content://")) {
          Content content =
              await ContentResolver.resolveContent(value.first.path);
          source = utf8.decode(content.data.toList());
        } else {
          source = File.fromUri(Uri.parse(value.first.path)).readAsStringSync();
        }
      } catch (e) {
        if (mounted) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              "homepage.input_partner_data.failed_get_file",
            ),
          );
          log.error("Import partner classtable error.", e);
          return;
        }
      }

      if (mounted) {
        try {
          final data = jsonDecode(source);

          String semesterCode = Get.put(
            ClassTableController(),
          ).classTableData.semesterCode;

          var yearNotEqual = semesterCode.substring(0, 4).compareTo(
                  data["classtable"]["semesterCode"]
                      .toString()
                      .substring(0, 4)) !=
              0;
          var lastNotEqual = semesterCode
                  .substring(semesterCode.length - 1)
                  .compareTo(
                      data["classtable"]["semesterCode"].toString().substring(
                            data["classtable"]["semesterCode"].length - 1,
                          )) !=
              0;
          if (yearNotEqual || lastNotEqual) {
            throw NotSameSemesterException(
              msg: "Not the same semester. This semester: $semesterCode. "
                  "Input source: ${data["classtable"]["semesterCode"]}."
                  "This partner classtable is going to be deleted.",
            );
          }
          File(
            "${supportPath.path}/${ClassTableFile.partnerClassName}",
          ).writeAsStringSync(source);
        } catch (error, stacktrace) {
          log.error(
            "Error occured while importing partner class.",
            error,
            stacktrace,
          );
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              "homepage.input_partner_data.failed_import",
            ),
          );
          return;
        }
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "homepage.input_partner_data.success_message",
          ),
        );
      }
    } else {
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          "homepage.input_partner_data.not_loaded",
        ),
      );
    }

    ReceiveSharingIntent.instance.reset();
  }

  void _showOfflineModeNotice() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(FlutterI18n.translate(
            context,
            "homepage.offline_mode_title",
          )),
          content: Text(FlutterI18n.translate(
            context,
            "homepage.offline_mode_content",
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterI18n.translate(context, "confirm")),
            ),
          ],
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!refreshAtStart) {
      message.checkMessage();
      message.checkUpdate().then((value) {
        if (value ?? false) _showUpdateNotice();
      });
      log.info(
        "[home][BackgroundFetchFromHome]"
        "Current loginstate: $loginState, if none will _loginAsync.",
      );
      if (loginState == IDSLoginState.none) {
        _loginAsync();
      } else {
        update(
          context: context,
          forceRetryLogin: true,
          sliderCaptcha: (String cookieStr) {
            return SliderCaptchaClientProvider(cookie: cookieStr)
                .solve(context);
          },
        );
      }
      refreshAtStart = true;
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) _intentSub.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      PageInformation(
        index: 0,
        name: FlutterI18n.translate(context, "homepage.homepage"),
        icon: MingCuteIcons.mgc_home_3_line,
        iconChoice: MingCuteIcons.mgc_home_3_fill,
      ),
      PageInformation(
        index: 1,
        name: FlutterI18n.translate(context, "homepage.planet"),
        icon: MingCuteIcons.mgc_planet_line,
        iconChoice: MingCuteIcons.mgc_planet_fill,
      ),
      PageInformation(
        index: 2,
        name: FlutterI18n.translate(context, "homepage.setting"),
        icon: MingCuteIcons.mgc_user_2_line,
        iconChoice: MingCuteIcons.mgc_user_2_fill,
      ),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _pageView,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        height: 64,
        destinations: destinations
            .map(
              (e) => NavigationDestination(
                icon: _selectedIndex == e.index
                    ? Icon(e.iconChoice)
                    : Icon(e.icon),
                label: e.name,
              ),
            )
            .toList(),
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          _controller.jumpToPage(_selectedIndex);
        },
      ),
    );
  }
}
