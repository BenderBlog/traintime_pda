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
  /// Colors from
  /// https://github.com/zfman/TimetableView/blob/master/AndroidTimetableView/TimetableView/res/values/colors.xml
  static const colorList = [
    // color_1 to color_11
    Color(0xFFAAA3DB),
    Color(0xFF86ACE9),
    Color(0xFF92D261),
    Color(0xFF80D8A3),
    Color(0xFFF1C672),
    Color(0xFFFDAD8B),
    Color(0xFFADBEFF),
    Color(0xFF94D6FA),
    Color(0xFFC3B5F6),
    Color(0xFF99CCFF),
    Color(0xFFFBA6ED),
    // color_30 to color_35
    Color(0xFFEE8262),
    Color(0xFFEE6363),
    Color(0xFFEEB4B4),
    Color(0xFFD2B48C),
    Color(0xFFCD9B9B),
    Color(0xFF5F9EA0),
  ];
  // Useless colors
  static const uselessColor = Color(0xFFE6E6E6);

  List<String> weekList = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  // The start day of the semester.
  var startDay = DateTime.parse(classData.termStartDay);

  List<DateTime> dateList = [];

  int currentWeekIndex = 0;

  String pageTitle = "我的课表";

  double aspect = 15;

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
                                Text(weekList[index - 1],
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: (dateList[index - 1].month ==
                                                    DateTime.now().month &&
                                                dateList[index - 1].day ==
                                                    DateTime.now().day)
                                            ? Colors.lightBlue
                                            : Colors.black87)),
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
                                            : Colors.black87)),
                              ],
                            ),
                    ),
                  );
                }),
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

        // Do not include itself and empty spaces...
        conflict.remove(places);
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
          (index) => _classCard(
              index, (MediaQuery.of(context).size.height / 15), null));
    }
  }

  Widget _classCard(int index, double height, Set<int>? conflict) => SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: conflict != null
                  ? index == -1
                      ? const Color(0x00000000)
                      : colorList[index % 17]
                  : const Color(0x00000000),
            ),
            child: Center(
              child: Text(
                conflict == null
                    ? "${index + 1}"
                    : index == -1
                        ? "$index BOCCHI RULES!"
                        : "${classData.onTable[index].toString()}\n${conflict.isEmpty ? "无冲突" : "重叠${conflict.length}"}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: conflict == null ? Colors.black : Colors.white,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      );
}
