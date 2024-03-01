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
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/class_not_arranged/not_arranged_class_list.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:share_plus/share_plus.dart';

class ClassTablePage extends StatefulWidget {
  const ClassTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassTablePageState();
}

class _ClassTablePageState extends State<ClassTablePage>
    with TickerProviderStateMixin {
  /// Check whether listener is pushed...
  bool isPushedListener = false;

  /// A lock of the week choice row.
  /// When locked, choiceWeek cannot be changed.
  bool isInit = false;
  late TabController _tabController;

  File image = File("${supportPath.path}/decoration.jpg");
  late ClassTableWidgetState classTableState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    classTableState = ClassTableState.of(context)!.controllers;
    if (!isInit) {
      _tabController = TabController(
        vsync: this,
        length: classTableState.semesterLength,
        initialIndex: classTableState.chosenWeek,
      );
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
          title: const Text("日程表"),
          leading: IconButton(
            icon: Icon(
              Platform.isIOS || Platform.isMacOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
            ),
            onPressed: () => Navigator.of(
              ClassTableState.of(context)!.parentContext,
            ).pop(),
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
                    child: Text("添加课程信息"),
                  ),
                  const PopupMenuItem<String>(
                    value: 'D',
                    child: Text("生成日历文件"),
                  ),
                ],
                onSelected: (String action) async {
                  final box = context.findRenderObject() as RenderBox?;
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
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabAlignment: TabAlignment.start,
            tabs: List.generate(
              classTableState.semesterLength,
              (index) => Tab(
                text: "第${index + 1}周",
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const ClassTablePageViewScrollPhysics(),
          children: List<Widget>.generate(
            classTableState.semesterLength,
            (index) => LayoutBuilder(
              builder: (context, constraint) => ClassTableView(
                constraint: constraint,
                index: index,
              ),
            ),
          ),
        )
            .decorated(
              image: (preference.getBool(preference.Preference.decorated) &&
                      image.existsSync())
                  ? DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                      opacity: Theme.of(context).brightness == Brightness.dark
                          ? 0.4
                          : 1.0,
                    )
                  : null,
            )
            .safeArea(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("日程表"),
          leading: IconButton(
            icon: Icon(
              Platform.isIOS || Platform.isMacOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
            ),
            onPressed: () => Navigator.of(
              ClassTableState.of(context)!.parentContext,
            ).pop(),
          ),
        ),
        body: const EmptyClasstablePage(),
      );
    }
  }
}

class ClassTablePageViewScrollPhysics extends ScrollPhysics {
  const ClassTablePageViewScrollPhysics({super.parent});

  @override
  ClassTablePageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ClassTablePageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
