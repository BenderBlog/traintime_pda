// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/page/classtable/class_change_list.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/week_choice_button.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'dart:developer' as developer;

class ClassTablePage extends StatefulWidget {
  const ClassTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassTablePageState();
}

class _ClassTablePageState extends State<ClassTablePage> {
  /// A lock of the week choice row.
  /// When locked, choiceWeek cannot be changed.
  bool isTopRowLocked = false;

  /// Classtable pageView controller.
  late PageController pageControl;

  /// Week choice row controller.
  late PageController rowControl;

  late BoxDecoration decoration;
  late ClassTableState classTableState;

  @override
  void didChangeDependencies() {
    classTableState = ClassTableState.of(context)!;
    pageControl = PageController(
      initialPage: classTableState.controllers.chosenWeek,
      keepPage: true,
    );

    /// (weekButtonWidth + 2 * weekButtonHorizontalPadding)
    /// is the width of the week choose button.
    rowControl = PageController(
      initialPage: classTableState.controllers.chosenWeek,
      viewportFraction: (weekButtonWidth + 2 * weekButtonHorizontalPadding) /
          MediaQuery.sizeOf(context).width,
      keepPage: true,
    );

    /// Init the background.
    File image = File("${supportPath.path}/decoration.jpg");
    decoration = BoxDecoration(
      image: (preference.getBool(preference.Preference.decorated) &&
              image.existsSync())
          ? DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
              opacity:
                  Theme.of(context).brightness == Brightness.dark ? 0.4 : 1.0,
            )
          : null,
    );

    super.didChangeDependencies();
  }

  /// Change the position in the topRow
  void changeTopRow(int index) => rowControl.animateTo(
        (weekButtonWidth + 2 * weekButtonHorizontalPadding) * index,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: changePageTime),
      );

  /// A row shows a series of buttons about the classtable's index.
  ///
  /// This is at the top of the classtable. It contains a series of
  /// buttons which shows the week index, as well as an overview in a 5x5 dot gridview.
  ///
  /// When user click on the button, the pageview will show the class table of the
  /// week the button suggested.
  Widget _topView() {
    return SizedBox(
      /// Related to the overview of the week.
      height: MediaQuery.sizeOf(context).height >= 500
          ? topRowHeightBig
          : topRowHeightSmall,
      child: Container(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 4,
        ),
        child: PageView.builder(
          controller: rowControl,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: classTableState.semesterLength,
          itemBuilder: (BuildContext context, int index) {
            return WeekChoiceButton(
              onTap: () {
                isTopRowLocked = true;

                /// The following sequence is used when triggering changing page.
                ///  * topRowLocked
                ///  * change the chosen week
                ///  * trigger pageview controller [pageControl] change, as well as
                ///  * change the [WeekChoiceRow]
                classTableState.controllers.chosenWeek = index;
                pageControl.animateToPage(
                  index,
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: changePageTime),
                );
                changeTopRow(index);

                setState(() {});
              },
              index: index,
            );
          },
        ),
      ),
    );
  }

  /// If no class, a special page appears.
  bool get haveClass =>
      classTableState.timeArrangement.isNotEmpty &&
      classTableState.classDetail.isNotEmpty;

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
          if (haveClass)
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                const PopupMenuItem<String>(
                  value: 'A',
                  child: Text("查看未安排课程信息"),
                ),
                const PopupMenuItem<String>(
                  value: 'B',
                  child: Text("查看课程安排调整信息"),
                ),
                const PopupMenuItem<String>(
                  value: 'C',
                  child: Text("生成日历文件"),
                ),
              ],
              onSelected: (String action) async {
                // 点击选项的时候
                switch (action) {
                  case 'A':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return NotArrangedClassList(
                            notArranged: classTableState.notArranged,
                          );
                        },
                      ),
                    );
                    break;
                  case 'B':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return ClassChangeList(
                            classChanges: classTableState.classChange,
                          );
                        },
                      ),
                    );
                    break;
                  case 'C':
                    try {
                      String? result =
                          await FilePicker.platform.getDirectoryPath(
                        dialogTitle: "保存日历文件到哪里呢",
                      );
                      if (result == null) {
                        Fluttertoast.showToast(msg: "没选择目录，保存取消");
                        return;
                      }
                      await Fluttertoast.showToast(msg: "理论保存地址：$result");
                      /*
                      String now = Jiffy.now().format(
                        pattern: "yyyyMMddTHHmmss",
                      );
                      String semester = classTableState.semesterCode;
                      File file = File("$result/classtable-$now-$semester.ics");
                      developer.log("File exists? ${file.existsSync()}");
                      if (!(await file.exists())) {
                        file = await file.create();
                      }

                      file = await file.writeAsString(
                        classTableState.iCalenderStr,
                      );
                      developer.log(
                          "$file ${file.lengthSync()} ${classTableState.iCalenderStr.length}");
                      Fluttertoast.showToast(msg: "应该保存成功");
                      */
                    } on FileSystemException {
                      Fluttertoast.showToast(msg: "文件创建失败，保存取消");
                    }

                    break;
                }
              },
            ),
        ],
      ),
      body: haveClass
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                PreferredSize(
                  preferredSize: Size.fromHeight(
                    MediaQuery.sizeOf(context).height >= 500
                        ? topRowHeightBig
                        : topRowHeightSmall,
                  ),
                  child: _topView(),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: decoration,
                    child: _classTablePage(),
                  ),
                ),
              ],
            )
          : Container(
              decoration: decoration,
              // color: Colors.grey.shade200.withOpacity(0.75),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "${ClassTableState.of(context)!.semesterCode} 学期没有课程，不会吧?",
                    ),
                    const Text("如果刚选完课，过几天就更新了吧。"),
                    const Text("如果你没选课，快去 xk.xidian.edu.cn！"),
                    const Text("如果你要毕业了，祝你前程似锦。"),
                    const Text("如果你已经毕业，快去关注 SuperBart 哔哩哔哩帐号！"),
                  ],
                ),
              ),
            ),
    );
  }

  /// The [_classTablePage] is controlled by [pageControl].
  Widget _classTablePage() => PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: pageControl,
        onPageChanged: (value) {
          /// When [pageControl.animateTo] triggered,
          /// page view will try to refresh the [chosenWeek] everytime the page
          /// view changed into a new page. Because animateTo will load every page
          /// it passed.
          ///
          /// So that's the [isTopRowLocked] is used for. When week choice row is
          /// locked, it will not refresh the [chosenWeek]. And when [chosenWeek]
          /// is equal to the current page, unlock the [isTopRowLocked].
          if (!isTopRowLocked) {
            setState(() {
              changeTopRow(value);
              classTableState.controllers.chosenWeek = value;
            });
          }
          if (classTableState.controllers.chosenWeek == value) {
            isTopRowLocked = false;
          }
        },
        itemCount: classTableState.semesterLength,
        itemBuilder: (context, index) => LayoutBuilder(
          builder: (context, constraint) => ClassTableView(
            constraint: constraint,
            index: index,
          ),
        ),
      );
}
