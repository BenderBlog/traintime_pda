import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/homepage.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/page/xdu_planet/mainpage.dart';
import 'package:watermeter/page/xidian_directory/xidian_directory.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  Widget _buildPhone() => Scaffold(
        body: PageView(
          controller: _controller,
          children: _page,
          onPageChanged: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        bottomNavigationBar: NavigationBar(
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
        ),
      );

  Widget _buildPad() => Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
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
              Expanded(
                child: PageView(
                  controller: _controller,
                  children: _page,
                  onPageChanged: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return isPhone(context) ? _buildPhone() : _buildPad();
  }
}
