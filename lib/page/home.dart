import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/homepage.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/page/xdu_planet/mainpage.dart';
import 'package:watermeter/page/xidian_directory/xidian_directory.dart';
import 'package:watermeter/repository/network_session.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final _destinations = [
    PageInformation(
      index: 0,
      name: "主页",
      icon: Icons.home,
      iconChoice: Icons.home_outlined,
    ),
    PageInformation(
      index: 1,
      name: "西电目录",
      icon: Icons.store,
      iconChoice: Icons.store_outlined,
    ),
    PageInformation(
      index: 2,
      name: "XDU Planet",
      icon: Icons.feed,
      iconChoice: Icons.feed_outlined,
    ),
    PageInformation(
      index: 3,
      name: "设置",
      icon: Icons.settings,
      iconChoice: Icons.settings_outlined,
    ),
  ];

  static final _page = [
    const MainPage(),
    const XidianDirWindow(),
    const XDUPlanetPage(),
    const SettingWindow(),
  ];

  late PageController _controller;
  late PageView _pageView;
  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _pageView = PageView(
      controller: _controller,
      children: _page,
      onPageChanged: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );

    if (offline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Visibility(
              visible: !isPhone(context),
              child: NavigationRail(
                elevation: 20,
                destinations: _destinations
                    .map(
                      (e) => NavigationRailDestination(
                        icon: _selectedIndex == e.index
                            ? Icon(e.icon)
                            : Icon(e.iconChoice),
                        label: Text(e.name),
                      ),
                    )
                    .toList(),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _controller.jumpToPage(_selectedIndex);
                },
                leading: const Icon(Icons.person),
                extended: isDesktop(context),
              ),
            ),
            Expanded(
              child: _pageView,
            ),
          ],
        ),
      ),
      bottomNavigationBar: isPhone(context)
          ? NavigationBar(
              destinations: _destinations
                  .map(
                    (e) => NavigationDestination(
                      icon: _selectedIndex == e.index
                          ? Icon(e.icon)
                          : Icon(e.iconChoice),
                      label: e.name,
                    ),
                  )
                  .toList(),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
                _controller.jumpToPage(_selectedIndex);
              },
            )
          : null,
    );
  }
}
