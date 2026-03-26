// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Main page of this program.
import 'dart:io';
import 'dart:async';

import 'package:based_split_view/based_split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/pig/pig_page.dart';
import 'package:watermeter/page/public_widget/split_page_placeholder.dart';
import 'package:watermeter/page/toolbox/toolbox_page.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:restart_app/restart_app.dart';
import 'package:watermeter/page/homepage/homepage.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/repository/pda_service_session.dart' as message;
import 'package:watermeter/repository/preference.dart';
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
      leftWidget: HomePageMaster(key: leftKey),
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

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  void _loginAsync() async {
    updateCurrentData(); // load cache data
    showToast(
      context: context,
      msg: FlutterI18n.translate(context, "homepage.login_message"),
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
              title: Text(
                FlutterI18n.translate(context, "homepage.password_wrong_title"),
              ),
              content: Text(
                FlutterI18n.translate(
                  context,
                  "homepage.password_wrong_content",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //if (Platform.isAndroid || Platform.isIOS) {
                    Restart.restartApp();
                    //} else {
                    //  showDialog(
                    //    barrierDismissible: false,
                    //    context: context,
                    //    builder: (context) => AlertDialog(
                    //      title: Text(
                    //        FlutterI18n.translate(
                    //          context,
                    //          "setting.need_close_dialog.title",
                    //        ),
                    //      ),
                    //      content: Text(
                    //        FlutterI18n.translate(
                    //          context,
                    //          "setting.need_close_dialog.content",
                    //        ),
                    //      ),
                    //    ),
                    //  );
                    //}
                  },
                  child: Text(FlutterI18n.translate(context, "confirm")),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showOfflineModeNotice();
                  },
                  child: Text(
                    FlutterI18n.translate(
                      context,
                      "homepage.password_wrong_denial",
                    ),
                  ),
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

  void _showOfflineModeNotice() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            FlutterI18n.translate(context, "homepage.offline_mode_title"),
          ),
          content: Text(
            FlutterI18n.translate(context, "homepage.offline_mode_content"),
          ),
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
      message.checkUpdate();
      //message.getClubList();
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
            return SliderCaptchaClientProvider(
              cookie: cookieStr,
            ).solve(context);
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
        name: FlutterI18n.translate(context, "homepage.toolbox.toolbox"),
        icon: MingCuteIcons.mgc_tool_line,
        iconChoice: MingCuteIcons.mgc_tool_fill,
      ),
      PageInformation(
        index: 2,
        name: FlutterI18n.translate(context, "homepage.dashboard"),
        icon: MingCuteIcons.mgc_pig_line,
        iconChoice: MingCuteIcons.mgc_pig_fill,
      ),
      PageInformation(
        index: 3,
        name: FlutterI18n.translate(context, "homepage.setting"),
        icon: MingCuteIcons.mgc_user_2_line,
        iconChoice: MingCuteIcons.mgc_user_2_fill,
      ),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: _controller,
        children: [
          MainPage(
            changePage: () {
              setState(() {
                _selectedIndex = 1;
              });
              _controller.jumpToPage(_selectedIndex);
            },
          ),
          const ToolBoxPage(),
          const PigPage(),
          const SettingWindow(),
        ],
        onPageChanged: (int index) {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
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
        //labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (int index) {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
            _controller.jumpToPage(_selectedIndex);
          }
        },
      ),
    );
  }
}
