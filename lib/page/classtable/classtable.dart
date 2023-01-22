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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

class ClassTable extends StatelessWidget {
  final Classes toUse = classData;
  ClassTable({
    Key? key,
    /*required this.classData*/
  }) : super(key: key);

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
      body: LayoutBuilder(
        builder: (context, constraints) => ClassTableWindow(
          constraints: constraints,
          classData: classData,
        ),
      ),
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
  final Classes classData;
  final BoxConstraints constraints;
  const ClassTableWindow({
    super.key,
    required this.constraints,
    required this.classData,
  });

  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends State<ClassTableWindow> {
  // The height ratio for the top and the middle.
  static const heightRatio = [0.1, 0.08, 0.82];

  // The width ratio for the week column.
  static const weekWidthRatio = 0.13;

  // Colors for the class information card.
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
  // Colors for class information card which not in this week.
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

  // Time arrangements.
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
  var startDay = DateTime.parse("2022-01-22");

  // The date which shown in the table.
  List<DateTime> dateList = [];

  int currentWeekIndex = 0;

  String pageTitle = "我的课表";

  double aspect = 15;

  // Update the weeklist.
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
    startDay = DateTime.parse(widget.classData.termStartDay);

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

  // For the avaliable weeks in the class information.
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

  // The top row is used to change the weeks.
  Widget _topView() => SizedBox(
        height: widget.constraints.maxHeight * heightRatio[0],
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.classData.semesterLength,
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

  // The middle row is used to show the date and week.
  Widget _middleView() {
    Widget leftest = Container(
      color: Colors.white,
      width: widget.constraints.maxWidth * (1 - 7 * weekWidthRatio),
      child: Center(
        child: AutoSizeText(
          "课\n次",
          textAlign: TextAlign.center,
          group: AutoSizeGroup(),
          style: const TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
    );
    Widget weekInformation(int index) => Container(
          width: widget.constraints.maxWidth * weekWidthRatio,
          color: dateList[index - 1].month == DateTime.now().month &&
                  dateList[index - 1].day == DateTime.now().day
              ? const Color(0x00f7f7f7)
              : Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                weekList[index - 1],
                group: AutoSizeGroup(),
                textScaleFactor: 1.0,
                style: TextStyle(
                  //fontSize: 14,
                  color: (dateList[index - 1].month == DateTime.now().month &&
                          dateList[index - 1].day == DateTime.now().day)
                      ? Colors.lightBlue
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              AutoSizeText(
                "${dateList[index - 1].month}/${dateList[index - 1].day}",
                group: AutoSizeGroup(),
                textScaleFactor: 0.8,
                style: TextStyle(
                  color: (dateList[index - 1].month == DateTime.now().month &&
                          dateList[index - 1].day == DateTime.now().day)
                      ? Colors.lightBlue
                      : Colors.black87,
                ),
              ),
            ],
          ),
        );
    return SizedBox(
      height: widget.constraints.maxHeight * heightRatio[1],
      child: Row(
        children: List.generate(8, (index) {
          if (index > 0) {
            return weekInformation(index);
          } else {
            return leftest;
          }
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Top line to show the date
          _topView(),
          // The main class table.
          _middleView(),
          // The rest of the table.
          _classTable(),
        ],
      ),
    );
  }

  Widget _classTable() => Expanded(
        child: SingleChildScrollView(
            child: Row(
          children: List.generate(
              8,
              (i) => SizedBox(
                    width: i > 0
                        ? widget.constraints.maxWidth * weekWidthRatio
                        : widget.constraints.maxWidth *
                            (1 - 7 * weekWidthRatio),
                    child: Column(
                      children: _classSubRow(i),
                    ),
                  )),
        )),
      );

  List<Widget> _classSubRow(int index) {
    Widget classCard(int index, double height, Set<int> conflict) {
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
                    widget.classData.classDetail[index].toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: index != -1
                          ? colorList[index % colorList.length].shade800
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            );
      return SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            // Out
            borderRadius: BorderRadius.circular(7),
            child: Container(
              // Border
              color: index == -1
                  ? const Color(0x00000000)
                  : colorList[index % colorList.length].shade300,
              padding: conflict.length == 1
                  ? const EdgeInsets.all(1)
                  : const EdgeInsets.fromLTRB(1, 1, 1, 8),
              child: ClipRRect(
                // Inner
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  color: index == -1
                      ? const Color(0x00000000)
                      : colorList[index % colorList.length].shade100,
                  child: inside,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (index != 0) {
      List<Widget> thisRow = [];

      // 1. Choice the class in this day.
      List<TimeArrangement> thisDay = [];
      for (var i in widget.classData.timeArrangement) {
        if (i.weekList.length < widget.classData.semesterLength) {
          continue;
        }
        if (i.weekList[currentWeekIndex] == "1" && i.day == index) {
          thisDay.add(i);
        }
      }

      // 2. The longest class should be solved first.
      thisDay.sort((a, b) => b.step.compareTo(a.step));

      // 3. Arrange the layout. Solve the conflex.
      List<List<int>> pretendLayout = List.generate(10, (index) => <int>[]);
      for (var i in thisDay) {
        for (int j = i.start - 1; j <= i.stop - 1; ++j) {
          pretendLayout[j].add(i.index);
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
        thisRow.add(classCard(
          places,
          count * widget.constraints.maxHeight * heightRatio[2] / 10,
          conflict,
        ));
      }

      return thisRow;
    } else {
      // Leftest side, the index array.
      return List.generate(
        10,
        (index) => SizedBox(
          height: widget.constraints.maxHeight * heightRatio[2] / 10,
          child: Center(
            child: AutoSizeText(
              "${index + 1}",
              group: AutoSizeGroup(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buttomInformation(Set<int> conflict) {
    List<TimeArrangement> information = List.generate(conflict.length,
        (index) => widget.classData.timeArrangement[conflict.elementAt(index)]);

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

  Widget _classInfoBox(TimeArrangement i) {
    ClassDetail toShow = widget.classData.classDetail[i.index];
    return Card(
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
                Text(toShow.name),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(),
                Text(toShow.teacher ?? "老师未定"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.room),
                const SizedBox(),
                Text(toShow.place ?? "地点未定"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(),
                Text(
                    "${i.start}-${i.stop}节课 ${time[(i.start - 1) * 2]}-${time[(i.stop - 1) * 2 + 1]}"),
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
}
