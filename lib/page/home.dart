import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/homepage.dart';
import 'package:watermeter/page/setting/setting.dart';
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

List<PageInformation> destinations = [
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final _page = [
    MainPage(),
    const XidianDirWindow(),
    const Placeholder(),
    const SettingWindow(),
  ];

  bool _isPhone(context) => MediaQuery.of(context).size.width < 600;
  bool _isDesktop(context) => MediaQuery.of(context).size.width > 840;

  Widget _buildPhone() => Scaffold(
        body: _page[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          destinations: destinations
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
          },
        ),
      );

  Widget _buildPad() => Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                destinations: destinations
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
                },
              ),
              Expanded(child: _page[_selectedIndex]),
            ],
          ),
        ),
      );

  Widget _buildDesktop() => Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationDrawer(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: destinations
                    .map((e) => NavigationDrawerDestination(
                          label: Text(e.name),
                          icon: Icon(e.icon),
                          selectedIcon: Icon(e.iconChoice),
                        ))
                    .toList(),
              ),
              Expanded(child: _page[_selectedIndex]),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _isPhone(context)
        ? _buildPhone()
        : _isDesktop(context)
            ? _buildDesktop()
            : _buildPad();
  }
}
