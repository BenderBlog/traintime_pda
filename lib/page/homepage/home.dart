// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Main page of this program.
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:based_split_view/based_split_view.dart';
import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/public_widget/split_page_placeholder.dart';
import 'package:watermeter/page/xdu_planet/xdu_planet_page.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:restart_app/restart_app.dart';
import 'package:watermeter/page/homepage/homepage.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/repository/message_session.dart' as message;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart';
import 'package:watermeter/repository/xidian_ids/ehall_classtable_session.dart';
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      updateCurrentData();
    }
  }

  static final _destinations = [
    PageInformation(
      index: 0,
      name: "主页",
      icon: MingCuteIcons.mgc_home_3_line,
      iconChoice: MingCuteIcons.mgc_home_3_fill,
    ),
    PageInformation(
      index: 1,
      name: "XDU Planet",
      icon: MingCuteIcons.mgc_planet_line,
      iconChoice: MingCuteIcons.mgc_planet_fill,
    ),
    PageInformation(
      index: 2,
      name: "设置",
      icon: MingCuteIcons.mgc_user_2_line,
      iconChoice: MingCuteIcons.mgc_user_2_fill,
    ),
  ];
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
      Future<void> onData(List<SharedMediaFile> value) async {
        log.info("Input data: ${value.first.path}");

        if (Uri.tryParse(value.first.path) == null) {
          showToast(context: context, msg: "导入路径不存在:P");
          ReceiveSharingIntent.instance.reset();
          return;
        }
        log.info("Partner File Position: ${value.first.path}");

        final c = Get.find<ClassTableController>();
        if (c.state != ClassTableState.fetched) {
          showToast(
            context: context,
            msg: "还没加载课程表，等会再来吧……",
          );
          return;
        }
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
              title: const Text("确认对话框"),
              content: const Text("目前有搭子课表数据，是否要覆盖？"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("取消"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("确定"),
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
            source =
                File.fromUri(Uri.parse(value.first.path)).readAsStringSync();
          }
        } catch (e) {
          if (mounted) {
            showToast(
              context: context,
              msg: '导入文件失败',
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

            if (semesterCode
                    .compareTo(data["classtable"]["semesterCode"].toString()) !=
                0) {
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
              msg: '好像导入文件有点问题:P',
            );
            return;
          }
          showToast(
            context: context,
            msg: '导入成功，如果打开了课表页面请重新打开',
          );
        }

        ReceiveSharingIntent.instance.reset();
      }

      // Listen to media sharing coming from outside the app while the app is in the memory.
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(onData,
          onError: (error, stacktrace) {
        log.error("getIntentDataStream error.", error, stacktrace);
      });
      // Get the media sharing coming from outside the app while the app is closed.
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then(onData)
          .catchError((err, stacktrace) {
        log.error("getIntentDataStream error.", err, stacktrace);
      });
    }
    message.checkMessage();
    log.info(
      "[home][BackgroundFetchFromHome]"
      "Current loginstate: $loginState, if none will _loginAsync.",
    );
    if (loginState == IDSLoginState.none) {
      _loginAsync();
    } else {
      update(
        forceRetryLogin: true,
        sliderCaptcha: (String cookieStr) {
          return SliderCaptchaClientProvider(cookie: cookieStr).solve(context);
        },
      );
    }
  }

  void _loginAsync() async {
    updateCurrentData(); // load cache data
    showToast(context: context, msg: "登录中，暂时显示缓存数据");

    try {
      await update(
        forceRetryLogin: true,
        sliderCaptcha: (String cookieStr) {
          return SliderCaptchaClientProvider(cookie: cookieStr).solve(context);
        },
      );
    } finally {
      if (loginState == IDSLoginState.success) {
        if (mounted) {
          showToast(context: context, msg: "登录成功");
        }
      } else if (loginState == IDSLoginState.passwordWrong) {
        await preference.remove(preference.Preference.idsPassword);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("用户名或密码有误"),
              content: const Text("是否重启应用后手动登录？"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Restart.restartApp();
                  },
                  child: const Text("是"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showOfflineModeNotice();
                  },
                  child: const Text("否，进入离线模式"),
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
          title: const Text("统一认证服务离线模式开启"),
          content: const Text(
            "无法连接到统一认证服务服务器，所有和其相关的服务暂时不可用。\n"
            "成绩查询，考试信息查询，欠费查询，校园卡查询关闭。课表显示缓存数据。其他功能暂不受影响。\n"
            "如有不便，敬请谅解。",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("确定"),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) _intentSub.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _pageView,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        height: 64,
        destinations: _destinations
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
