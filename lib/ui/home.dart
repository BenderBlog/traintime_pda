import 'package:flutter/material.dart';
import 'package:watermeter/ui/tool/score/score.dart';
import 'package:watermeter/ui/tool/sport/sportWindow.dart';
import 'package:watermeter/ui/tool/setting/setting.dart';
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
      body: ToolWindow(contextFromPage: context),
    );
  }
}

class ToolWindow extends StatelessWidget {

  final BuildContext contextFromPage;
  const ToolWindow({Key? key, required this.contextFromPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
            crossAxisCount: 2,
            children: [
              MaterialButton(
                color: Colors.cyan,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.run_circle_outlined, size: 96.0,),
                    SizedBox(height: 10),
                    Text("体育查询", textScaleFactor: 1.5,),
                  ],
                ),
                onPressed: () {
                  Navigator.of(contextFromPage).push(
                    MaterialPageRoute(builder: (context) {
                      return const SportWindow();
                    }),
                  );
                },
              ),
              MaterialButton(
                color: Colors.orange,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.score, size: 96.0,),
                    SizedBox(height: 10),
                    Text("成绩查询", textScaleFactor: 1.5,),
                  ],
                ),
                onPressed: () {
                  Navigator.of(contextFromPage).push(
                    MaterialPageRoute(builder: (context) {
                      return const ScoreWindow();
                    }),
                  );
                },
              ),
              MaterialButton(
                color: Colors.yellowAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.nightlife, size: 96.0,),
                    SizedBox(height: 10,),
                    Text("生活信息", textScaleFactor: 1.5,),
                  ],
                ),
                onPressed: () {
                  Navigator.of(contextFromPage).push(
                    MaterialPageRoute(builder: (context) {
                      return const XidianDirWindow();
                    }),
                  );
                },
              ),
              MaterialButton(
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.settings, size: 96.0,),
                    SizedBox(height: 10,),
                    Text("设置", textScaleFactor: 1.5,),
                  ],
                ),
                onPressed: () {
                  Navigator.of(contextFromPage).push(
                    MaterialPageRoute(builder: (context) {
                      return const SettingWindow();
                    }),
                  );
                },
              ),
            ]
    );
  }
}

