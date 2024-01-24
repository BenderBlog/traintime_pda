// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_change/class_change_list.dart';
import 'package:watermeter/page/classtable/class_page/empty_classtable_page.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/class_not_arranged/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/class_page/week_choice_button.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:share_plus/share_plus.dart';

class ClassTablePage extends StatefulWidget {
  const ClassTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassTablePageState();
}

class _ClassTablePageState extends State<ClassTablePage> {
  /// Check whether listener is pushed...
  bool isPushedListener = false;

  /// A lock of the week choice row.
  /// When locked, choiceWeek cannot be changed.
  bool isTopRowLocked = false;

  /// Classtable pageView controller.
  late PageController pageControl;

  /// Week choice row controller.
  late PageController rowControl;

  File image = File("${supportPath.path}/decoration.jpg");
  late ClassTableWidgetState classTableState;

  void _switchPage() {
    setState(() => isTopRowLocked = true);
    Future.wait(
      [
        rowControl.animateTo(
          (weekButtonWidth + 2 * weekButtonHorizontalPadding) *
              classTableState.chosenWeek,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: changePageTime),
        ),
        pageControl.animateToPage(
          classTableState.chosenWeek,
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: changePageTime),
        ),
      ],
    ).then((value) => isTopRowLocked = false);
  }

  @override
  void dispose() {
    classTableState.removeListener(_switchPage);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    classTableState = ClassTableState.of(context)!.controllers;

    pageControl = PageController(
      initialPage: classTableState.chosenWeek,
      keepPage: true,
    );

    /// (weekButtonWidth + 2 * weekButtonHorizontalPadding)
    /// is the width of the week choose button.
    rowControl = PageController(
      initialPage: classTableState.chosenWeek,
      viewportFraction: (weekButtonWidth + 2 * weekButtonHorizontalPadding) /
          MediaQuery.sizeOf(context).width,
      keepPage: true,
    );

    /// Let controllers listen to the currentWeek's change.
    if (isPushedListener == false) {
      classTableState.addListener(_switchPage);
      isPushedListener = true;
    }

    super.didChangeDependencies();
  }

  /// If no class, a special page appears.
  bool get haveClass =>
      classTableState.timeArrangement.isNotEmpty &&
      classTableState.classDetail.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (haveClass) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("课程表"),
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
                    child: Text("添加课程信息"),
                  ),
                  const PopupMenuItem<String>(
                    value: 'D',
                    child: Text("生成日历文件"),
                  ),
                ],
                onSelected: (String action) async {
                  final box = context.findRenderObject() as RenderBox?;

                  // 点击选项的时候
                  switch (action) {
                    case 'A':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const NotArrangedClassList();
                          },
                        ),
                      );
                      break;
                    case 'B':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const ClassChangeList();
                          },
                        ),
                      );
                      break;
                    case 'C':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const ClassAddWindow();
                          },
                        ),
                      );
                      break;
                    case 'D':
                      try {
                        String now = Jiffy.now().format(
                          pattern: "yyyyMMddTHHmmss",
                        );
                        String semester = classTableState.semesterCode;
                        String tempPath = await getTemporaryDirectory()
                            .then((value) => value.path);
                        File file = File(
                          "$tempPath/classtable-$now-$semester.ics",
                        );
                        if (!(await file.exists())) {
                          await file.create();
                        }
                        await file.writeAsString(classTableState.iCalenderStr);
                        await Share.shareXFiles(
                          [XFile("$tempPath/classtable-$now-$semester.ics")],
                          sharePositionOrigin:
                              box!.localToGlobal(Offset.zero) & box.size,
                        );
                        await file.delete();
                        Fluttertoast.showToast(msg: "应该保存成功");
                      } on FileSystemException {
                        Fluttertoast.showToast(msg: "文件创建失败，保存取消");
                      }
                      break;
                  }
                },
              ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// Following is a row shows a series of buttons related to the classtable's index.
            ///
            /// This is at the top of the classtable. It contains a series of
            /// buttons which shows the week index, as well as an overview in a 5x5 dot gridview.
            ///
            /// When user click on the button, the pageview will show the class table of the
            /// week the button suggested.
            PageView.builder(
              controller: rowControl,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: classTableState.semesterLength,
              itemBuilder: (BuildContext context, int index) {
                return WeekChoiceButton(
                  onTap: () {
                    if (isTopRowLocked == false) {
                      classTableState.chosenWeek = index;
                    }
                  },
                  index: index,
                );
              },
            )
                .padding(
                  top: 2,
                  bottom: 4,
                )
                .constrained(
                  height: MediaQuery.sizeOf(context).height >= 500
                      ? topRowHeightBig
                      : topRowHeightSmall,
                ),
            PageView.builder(
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
                if (isTopRowLocked == false) {
                  classTableState.chosenWeek = value;
                }
              },
              itemCount: classTableState.semesterLength,
              itemBuilder: (context, index) => LayoutBuilder(
                builder: (context, constraint) => ClassTableView(
                  constraint: constraint,
                  index: index,
                ),
              ),
            )
                .decorated(
                  image: (preference.getBool(preference.Preference.decorated) &&
                          image.existsSync())
                      ? DecorationImage(
                          image: FileImage(image),
                          fit: BoxFit.cover,
                          opacity:
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.4
                                  : 1.0,
                        )
                      : null,
                )
                .expanded(),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("课程表"),
        ),
        body: const EmptyClasstablePage(),
      );
    }
  }
}
