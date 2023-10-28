// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

/// A new page to show the class changed.
///
/// When executing [Navigator.of(context).push()], the page is not mounted under
/// the [ClassTableState] node on the Widget Tree, so I cannot use [ClassTableState.of(context)!].

class ClassChangeList extends StatelessWidget {
  /// A list of [ClassDetail] which do not have the time arrangement.
  final List<ClassChange> classChanges;
  const ClassChangeList({
    super.key,
    required this.classChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("课程调整"),
      ),
      body: ListView.builder(
          itemCount: classChanges.length,
          itemBuilder: (context, index) {
            ClassChange toShow = classChanges[index];

            String teacherChange = "";
            if (toShow.isTeacherChanged &&
                classChanges[index].newTeacher != null) {
              teacherChange +=
                  "从${classChanges[index].originalTeacher ?? "没有信息"}"
                  "变为${classChanges[index].newTeacher}";
            } else {
              teacherChange += "没有改变";
            }

            for (int i = 0; i < toShow.originalAffectedWeeksList.length; ++i) {
              toShow.originalAffectedWeeksList[i] += 1;
            }

            for (int i = 0; i < toShow.newAffectedWeeksList.length; ++i) {
              toShow.newAffectedWeeksList[i] += 1;
            }

            String classChange = "";
            switch (toShow.type) {
              case ChangeType.change:
                classChange +=
                    "调课信息,从${toShow.originalAffectedWeeksList}星期${toShow.originalWeek}的${toShow.originalClassRange[0]}-${toShow.originalClassRange[1]}节"
                    "调整为${toShow.newAffectedWeeksList}星期${toShow.newWeek}的${toShow.newClassRange[0]}-${toShow.newClassRange[1]}节,${toShow.newClassroom}教室上课";
                break;
              case ChangeType.patch:
                classChange +=
                    "补课信息,从${toShow.originalAffectedWeeksList}星期${toShow.originalWeek}的${toShow.originalClassRange[0]}-${toShow.originalClassRange[1]}节,${toShow.originalClassroom}补课";
                break;
              case ChangeType.stop:
                classChange +=
                    "停课信息,从${toShow.originalAffectedWeeksList}星期${toShow.originalWeek}的${toShow.originalClassRange[0]}-${toShow.originalClassRange[1]}节,${toShow.originalClassroom}停课";
                break;
            }

            return ListTile(
              title: Text(toShow.className),
              subtitle: Text(
                "编号: ${classChanges[index].classCode} | ${classChanges[index].classNumber} 班\n"
                "安排变更：$classChange\n"
                "老师变更: $teacherChange",
              ),
            );
          }),
    );
  }
}
