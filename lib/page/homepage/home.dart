// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Main page of this program.

import 'package:based_split_view/based_split_view.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/split_page_placeholder.dart';
import 'package:watermeter/page/xdu_planet/xdu_planet_page.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:restart_app/restart_app.dart';
import 'package:watermeter/page/homepage/homepage.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/repository/message_session.dart' as message;
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

  late PageController _controller;
  late PageView _pageView;
  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _pageView = PageView(
      controller: _controller,
      children: [
        const MainPage(),
        LayoutBuilder(
          builder: (context, constraints) => const XDUPlanetPage(),
        ),
        const SettingWindow(),
      ],
      onPageChanged: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
    WidgetsBinding.instance.addObserver(this);
    message.checkMessage();
    log.i(
      "[home][BackgroundFetchFromHome]"
      "Current loginstate: $loginState, if none will _loginAsync.",
    );
    if (loginState == IDSLoginState.none) {
      _loginAsync();
    } else {
      update(
        forceRetryLogin: true,
        sliderCaptcha: (String cookieStr) {
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CaptchaWidget(cookie: cookieStr),
            ),
          );
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
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CaptchaWidget(cookie: cookieStr),
            ),
          );
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _pageView,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
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
