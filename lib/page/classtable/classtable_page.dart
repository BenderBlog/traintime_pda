// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/week_choice_button.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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
  void initState() {
    /// Init the background.
    File image = File("${supportPath.path}/decoration.jpg");
    decoration = BoxDecoration(
      image: (preference.getBool(preference.Preference.decorated) &&
              image.existsSync())
          ? DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            )
          : null,
    );

    super.initState();
  }

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
            IconButton(
              icon: const Icon(Icons.cancel_schedule_send),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return NotArrangedClassList(
                        notArranged: classTableState.notArranged,
                      );
                    },
                  ),
                );
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      size: 100,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text("这个学期没有课程，不会吧?"),
                    Text("如果你没选课，快去 xk.xidian.edu.cn！"),
                    Text("如果你要毕业了，祝你前程似锦。"),
                    Text("如果你已经毕业，快去关注 SuperBart 哔哩哔哩帐号！"),
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
