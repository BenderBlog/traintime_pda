/*
Class Table
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/page/weight.dart';

class ClassTable extends StatelessWidget {
  const ClassTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("课程表"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const ClassTableWindow(),
    );
  }
}

class ClassTableWindow extends StatefulWidget {
  const ClassTableWindow({super.key});

  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends State<ClassTableWindow> {
  var colorList = [
    Colors.red,
    Colors.lightBlueAccent,
    Colors.grey,
    Colors.cyan,
    Colors.amber,
    Colors.deepPurpleAccent,
    Colors.purpleAccent
  ];
  var infoList = ["高等数学\nD-201", "大学英语\n信远I-501"];
  var weekList = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  var dateList = [];
  var currentWeekIndex = 0;


  @override
  void initState() {
    super.initState();

    var monday = 1;
    var mondayTime = DateTime.now();

    //获取本周星期一是几号
    while (mondayTime.weekday != monday) {
      mondayTime = mondayTime.subtract(const Duration(days: 1));
    }

    mondayTime.year;
    mondayTime.month;
    mondayTime.day;
    for (int i = 0; i < 7; i++) {
      dateList.add(
          "${mondayTime.month}/${mondayTime.day + i}");
      if ((mondayTime.day + i) == DateTime.now().day) {
        setState(() {
          currentWeekIndex = i + 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double aspect = 0.48;
    String chosenWeek = "";
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _topView,
          /// Top line to show the date
          SizedBox(
            child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1 / 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: index == currentWeekIndex
                        ? const Color(0x00f7f7f7)
                        : Colors.white,
                    child: Center(
                      child: index == 0
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("星期",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                          SizedBox(height: 5),
                          Text("日期", style: TextStyle(fontSize: 12)),
                        ],
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(weekList[index - 1],
                              style: TextStyle(
                                  fontSize: 14,
                                  color: index == currentWeekIndex
                                      ? Colors.lightBlue
                                      : Colors.black87)),
                          const SizedBox(height: 5),
                          Text(dateList[index - 1],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: index == currentWeekIndex
                                      ? Colors.lightBlue
                                      : Colors.black87)),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GridView.builder(
                        shrinkWrap: true,
                        // physics:ClampingScrollPhysics(),
                        itemCount: 10,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, childAspectRatio: aspect*2,),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              decoration: const BoxDecoration(
                                color: Color(0x00ff5ff5),
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black12, width: 0.5),
                                  right: BorderSide(
                                      color: Colors.black12, width: 0.5),
                                ),
                              ),
                              width: 25,
                              height: MediaQuery.of(context).size.height/5,
                              child: Center(
                                child: Text(
                                  (index + 1).toInt().toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                          );
                        }),
                  ),
                  Expanded(
                    flex: 7,
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 35,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, childAspectRatio: aspect),
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black12,
                                                width: 0.5),
                                            right: BorderSide(
                                                color: Colors.black12,
                                                width: 0.5),
                                          ),
                                        ),
                                      ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          // border: Border.all(color: Colors.black12, width: 0.5),
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black12,
                                                width: 0.5),
                                            right: BorderSide(
                                                color: Colors.black12,
                                                width: 0.5),
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                              if (index % 5 == 0 || index % 5 == 1)
                                Container(
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: colorList[index % 7],
                                  ),
                                  child: Center(
                                    child: Text(
                                      infoList[index % 2],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String pageTitle() => "我的课表";

  final Widget _topView = SizedBox(
    height: 80,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (BuildContext context, int index) {
          return TextButton(onPressed: (){}, child: Text("第$index周"));
        }),
  );
  /*
  Widget _centerView = Expanded(
    child: GridView.builder(
        itemCount: 63,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            // width: 25,
            // height: 80,
              child: Center(
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(fontSize: 15),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xff5ff5),
                border: Border.all(color: Colors.black12, width: 0.5),
              ));
        }),
  );

  Widget _bottomView = SizedBox(
    height: 30,
    child: Row(
      children: [
        //底部view可自行扩充
      ],
    ),
  );
  */
}