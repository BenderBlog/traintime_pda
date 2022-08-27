import 'package:flutter/material.dart';
import 'package:watermeter/ui/classtable/classtable.dart';
import 'package:watermeter/ui/links/links.dart';
import 'package:watermeter/ui/setting/setting.dart';
import 'package:watermeter/ui/tool/tool.dart';
import 'package:watermeter/ui/weight.dart';
import 'package:watermeter/ui/xidianDir/xidianDir.dart';
import 'package:watermeter/dataStruct/user.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WaterMeter"),
      ),
      drawer: MyDrawer(contextFromPage: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 10),
          ShadowBox(
            child: Center(child: Text("课表")),
          ),
          SizedBox(height: 40),
          ShadowBox(
            child: Center(child: Text("各种信息")),
          ),
          SizedBox(height: 40),
          ShadowBox(
            child: Center(child: Text("有用的链接")),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class MyDrawer extends Drawer {
  const MyDrawer({Key? key, required this.contextFromPage}) : super(key: key);
  final BuildContext contextFromPage;

  @override
  // TODO: implement child
  Widget? get child => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                  ),
                  child: Center(
                    child: Text(
                        "${user["name"]} ${user["subject"]} ${user["execution"]}\n"
                        "SuperBart Record Proudly Present WaterMeter"
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("课表"),
            onTap: () {
              Navigator.of(contextFromPage).push(
                MaterialPageRoute(builder: (context) {
                  return ClassTable();
                }),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text("工具箱"),
            onTap: () {
              Navigator.of(contextFromPage).push(
                MaterialPageRoute(builder: (context) {
                  return ToolWindow(contextFromPage: contextFromPage);
                }),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.nightlife),
            title: const Text("生活信息"),
            onTap: () {
              Navigator.of(contextFromPage).push(
                MaterialPageRoute(builder: (context) {
                  return const XidianDirWindow();
                }),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("有用的链接"),
            onTap: () {
              Navigator.of(contextFromPage).push(
                MaterialPageRoute(builder: (context) {
                  return const LinksWindow();
                }),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("设置"),
            onTap: () {
              Navigator.of(contextFromPage).push(
                MaterialPageRoute(builder: (context) {
                  return const SettingWindow();
                }),
              );
            },
          ),
        ],
      );
}
