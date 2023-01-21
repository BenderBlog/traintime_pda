/*
Class Table Interface.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
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
  static const colorList = [
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.orange,
    Colors.red,
  ];
  // Useless colors
  static const uselessColor = Colors.grey;

  List<String> weekList = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  // Even means start, odd means end.
  List<String> time = [
    "8:30",
    "9:15",
    "9:20",
    "10:05",
    "10:25",
    "11:10",
    "11:15",
    "12:00",
    "14:00",
    "14:45",
    "14:50",
    "15:35",
    "15:55",
    "16:40",
    "16:45",
    "17:30",
    "19:00",
    "19:45",
    "19:55",
    "20:30",
  ];

  // The start day of the semester.
  var startDay = DateTime.parse(classData.termStartDay);

  List<DateTime> dateList = [];

  int currentWeekIndex = 0;

  String pageTitle = "我的课表";

  double aspect = 15;

  Set<int> weekToShow(String weekList) {
    Set<int> toReturn =
        Set.from(List.generate(weekList.length, (index) => index + 1));
    for (int i = 0; i < weekList.length; ++i) {
      if (weekList[i] == "0") {
        toReturn.remove(i + 1);
      }
    }
    return toReturn;
  }

  void dateListUpdate() {
    DateTime firstDay = startDay.add(Duration(days: currentWeekIndex * 7));
    dateList = [firstDay];
    for (int i = 1; i < 7; ++i) {
      dateList.add(dateList.last.add(const Duration(days: 1)));
    }
  }

  @override
  void initState() {
    // Get the start day of the semester.
    var startDay = DateTime.parse(classData.termStartDay);

    // Get the current index.
    // If they decide to start the class in the next semester, well...
    if (DateTime.now().millisecondsSinceEpoch >=
        startDay.millisecondsSinceEpoch) {
      currentWeekIndex =
          (Jiffy(DateTime.now()).dayOfYear - Jiffy(startDay).dayOfYear) ~/ 7;
    }

    // Update dateList
    dateListUpdate();

    super.initState();
  }

  Widget _topView() => SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: classData.semesterLength,
          itemBuilder: (BuildContext context, int index) {
            return TextButton(
              style: TextButton.styleFrom(
                backgroundColor: currentWeekIndex == index
                    ? Colors.deepPurpleAccent
                    : Colors.white,
                foregroundColor: currentWeekIndex == index
                    ? Colors.white
                    : Colors.deepPurpleAccent,
              ),
              onPressed: () {
                setState(() {
                  currentWeekIndex = index;
                  dateListUpdate();
                });
              },
              child: Text("第${index + 1}周"),
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
                      ? const Color(0x00f7f7f7)
                      : Colors.white,
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
                              Text(
                                weekList[index - 1],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (dateList[index - 1].month ==
                                              DateTime.now().month &&
                                          dateList[index - 1].day ==
                                              DateTime.now().day)
                                      ? Colors.lightBlue
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${dateList[index - 1].month}/${dateList[index - 1].day}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (dateList[index - 1].month ==
                                              DateTime.now().month &&
                                          dateList[index - 1].day ==
                                              DateTime.now().day)
                                      ? Colors.lightBlue
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
          _classTable(),
        ],
      ),
    );
  }

  Widget _classTable() => Expanded(
          child: SingleChildScrollView(
              child: Row(
        children: List.generate(
            8, (i) => Expanded(child: Column(children: _classSubRow(i)))),
      )));

  List<Widget> _classSubRow(int index) {
    if (index != 0) {
      List<Widget> thisRow = [];

      // 1. Choice the class in this day.
      List<ClassDetail> thisDay = [];
      for (var element in classData.onTable) {
        if (element.weekList.length < classData.semesterLength) {
          continue;
        }
        if (element.weekList[currentWeekIndex] == "1" && element.day == index) {
          thisDay.add(element);
        }
      }

      // 2. The longest class should be solved first.
      thisDay.sort((a, b) => b.step.compareTo(a.step));

      // 3. Arrange the layout. Solve the conflex.
      List<List<int>> pretendLayout = List.generate(10, (index) => <int>[]);
      for (var i in thisDay) {
        for (int j = i.start - 1; j <= i.stop - 1; ++j) {
          pretendLayout[j].add(classData.onTable.indexOf(i));
        }
      }

      // 4. Deal with the empty space.
      for (var i in pretendLayout) {
        if (i.isEmpty) {
          i.add(-1);
        }
      }

      // 5. Render it!
      for (int i = 0; i < 10; ++i) {
        // Places in the onTable array.
        int places = pretendLayout[i].first;
        // The length to render.
        int count = 1;
        Set<int> conflict = pretendLayout[i].toSet();

        // Decide the length to render. i limit the end.
        while (i < 9 &&
            pretendLayout[i + 1].isNotEmpty &&
            pretendLayout[i + 1].first == places) {
          count++;
          i++;
          conflict.addAll(pretendLayout[i].toSet());
        }

        // Do not include empty spaces...
        conflict.remove(-1);

        // Generate the row.
        thisRow.add(_classCard(
          places,
          count * (MediaQuery.of(context).size.height / 15),
          conflict,
        ));
      }

      return thisRow;
    } else {
      // Leftest side, the index array.
      return List.generate(
        10,
        (index) => SizedBox(
          height: MediaQuery.of(context).size.height / 15,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // Uncommit to adjust the layout.
                // border: Border.all(),
                borderRadius: BorderRadius.circular(10),
                color: const Color(0x00000000),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _classCard(int index, double height, Set<int> conflict) {
    Widget inside = index == -1
        ? Padding(
            padding: const EdgeInsets.all(3),
            // Easter egg, usless you read the code, or reverse engineering...
            child: Center(
              child: Text(
                "BOCCHI RULES!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: index != -1
                      ? colorList[index % colorList.length].shade800
                      : Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          )
        : TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.resolveWith(
                (status) => EdgeInsets.zero,
              ),
              overlayColor: MaterialStateProperty.resolveWith(
                (status) => Colors.transparent,
              ),
            ),
            onPressed: () => showModalBottomSheet(
              builder: (((context) {
                return _buttomInformation(conflict);
              })),
              context: context,
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Center(
                child: Text(
                  classData.onTable[index].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: index != -1
                        ? colorList[index % colorList.length].shade800
                        : Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: index == -1
                ? null
                : Border.all(
                    width: 1,
                    color: colorList[index % colorList.length].withAlpha(128),
                  ),
            borderRadius: BorderRadius.circular(8),
            color: index == -1
                ? const Color(0x00000000)
                : colorList[index % colorList.length].shade100,
          ),
          child: inside,
        ),
      ),
    );
  }

  Widget _buttomInformation(Set<int> conflict) {
    List<ClassDetail> information = List.generate(conflict.length,
        (index) => classData.onTable[conflict.elementAt(index)]);

    List<Widget> toShow = [
      _classInfoBox(information.first),
    ];

    if (conflict.length > 1) {
      toShow.addAll([
        for (int i = 1; i < conflict.length; ++i) _classInfoBox(information[i]),
      ]);
    }

    return ListView(
      shrinkWrap: true,
      children: toShow,
    );
  }

  Widget _classInfoBox(ClassDetail i) => Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.class_),
                  const SizedBox(),
                  Text(i.name),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(),
                  Text(i.teacher ?? "老师未定"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.room),
                  const SizedBox(),
                  Text(i.place ?? "地点未定"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(),
                  Text(
                      "${time[(i.start - 1) * 2]} - ${time[(i.stop - 1) * 2 + 1]}"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(),
                  Expanded(
                    child: Text(
                      weekToShow(i.weekList).toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
