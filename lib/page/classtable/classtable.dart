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
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => aboutDialog(context),
              );
            },
          ),
        ],
      ),
      body: const ClassTableWindow(),
    );
  }

  Widget aboutDialog(context) => AlertDialog(
    title: const Text("不过我还是每次去教室"),
    content: Image.asset("assets/Farnsworth-Class.jpg"),
    actions: <Widget>[
      TextButton(
        child: const Text("确定"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
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

  List<String> weekList = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  List<DateTime> dateList = [];

  int currentWeekIndex = 0;

  String pageTitle = "我的课表";

  double aspect = 0.5;

  void dateListUpdate(DateTime firstDay) {
    dateList = [firstDay];
    for (int i = 1; i < 7; ++i){
      dateList.add(dateList.last.add(const Duration(days: 1)));
    }
  }

  @override
  void initState() {
    super.initState();

    // Get the start day of the semester.
    var startDay = DateTime.parse(classData.termStartDay);

    // Get the current index.
    currentWeekIndex = (Jiffy(DateTime.now()).dayOfYear - Jiffy(startDay).dayOfYear) ~/ 7;
    print(currentWeekIndex);

    // Update dateList
    dateListUpdate(classData.classTable[currentWeekIndex]!.startOfTheWeek);
  }

  Widget _topView() => SizedBox(
    height: 80,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: classData.classTable.length,
      itemBuilder: (BuildContext context, int index) {
        return TextButton(
          style: TextButton.styleFrom(
            backgroundColor: currentWeekIndex == index ? Colors.deepPurpleAccent : Colors.white,
            foregroundColor: currentWeekIndex == index ? Colors.white : Colors.deepPurpleAccent,
          ),
          onPressed: () {
            setState(() {
              currentWeekIndex = index;
              dateListUpdate(classData.classTable[currentWeekIndex]!.startOfTheWeek);
            });
          },
          child: Text("第${index+1}周"),
        );
      },
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Top line to show the date
          _topView(),
          // The main class table.
          SizedBox(
            child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: index != 0 &&
                        dateList[index - 1].month == DateTime.now().month &&
                        dateList[index - 1].day == DateTime.now().day
                         ? const Color(0x00f7f7f7) : Colors.white,
                    child: Center(
                      child: index == 0
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "星期",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
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
                                  color: (dateList[index - 1].month == DateTime.now().month &&
                                      dateList[index - 1].day == DateTime.now().day)
                                      ? Colors.lightBlue
                                      : Colors.black87)),
                          const SizedBox(height: 5),
                          Text("${dateList[index - 1].month}/${dateList[index - 1].day}",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: (dateList[index - 1].month == DateTime.now().month &&
                                      dateList[index - 1].day == DateTime.now().day)
                                      ? Colors.lightBlue
                                      : Colors.black87)),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          _classTable(classData.classTable[currentWeekIndex]!.classList),
        ],
      ),
    );
  }

  Widget _classTable(List<List<ClassDetail?>>? classTable) => Expanded(
    child: SingleChildScrollView(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GridView.builder(
                shrinkWrap: true,
                // physics:ClampingScrollPhysics(),
                itemCount: 10,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: aspect * 2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0x00ff5ff5),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black12,
                          width: 0.5,
                        ),
                        right: BorderSide(
                          color: Colors.black12,
                          width: 0.5,
                        ),
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
                itemCount: 70,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: aspect * 2,
                ),
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
                                    width: 0.5,
                                  ),
                                  right: BorderSide(
                                    color: Colors.black12,
                                    width: 0,
                                  ),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (classTable![index%7][index~/7] != null)
                        Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: colorList[index % 7],
                          ),
                          child: Center(
                            child: Text(
                              classTable[index%7][index~/7].toString(),
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
                },
            ),
          ),
        ],
      ),
    ),
  );
}