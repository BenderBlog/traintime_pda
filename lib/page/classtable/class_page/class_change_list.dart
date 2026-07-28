// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/generated/translations.g.dart';

/// A new page to show the class changed.
/// Shows a list of [ClassDetail] which do not have the time arrangement.

class ClassChangeList extends StatelessWidget {
  final List<ClassChange> classChanges;
  const ClassChangeList({super.key, required this.classChanges});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.classtable.classChangePage.title)),
      body: Builder(
        builder: (context) {
          if (classChanges.isEmpty) {
            return EmptyListView(
              type: EmptyListViewType.defaultimg,
              text: context.t.classtable.classChangePage.emptyMessage,
            );
          }

          return ListView.builder(
            itemCount: classChanges.length,
            itemBuilder: (context, index) {
              ClassChange toShow = classChanges[index];

              String teacherChange = "";
              if (classChanges[index].type != ChangeType.stop) {
                if (toShow.isTeacherChanged &&
                    classChanges[index].newTeacher != null) {
                  teacherChange += context.t.classtable.classChangePage
                      .teacherChange(
                        previous_teacher:
                            classChanges[index].originalTeacher ??
                            context.t.common.noInfo,
                        new_teacher: classChanges[index].originalNewTeacher!,
                      );
                } else {
                  teacherChange +=
                      context.t.classtable.classChangePage.noTeacherChange;
                }
              }

              String originalAffectedWeeksStr = "";
              for (
                int i = 0;
                i < toShow.originalAffectedWeeksList.length;
                ++i
              ) {
                originalAffectedWeeksStr +=
                    (toShow.originalAffectedWeeksList[i] + 1).toString();
                if (i + 1 != toShow.originalAffectedWeeksList.length) {
                  originalAffectedWeeksStr += ", ";
                }
              }

              String newAffectedWeeksListStr = "";
              for (int i = 0; i < toShow.newAffectedWeeksList.length; ++i) {
                newAffectedWeeksListStr += (toShow.newAffectedWeeksList[i] + 1)
                    .toString();
                if (i + 1 != toShow.newAffectedWeeksList.length) {
                  newAffectedWeeksListStr += ", ";
                }
              }

              String weekChar(int? week) {
                switch (week) {
                  case 1:
                    return context.t.classtable.classChangePage.k1;
                  case 2:
                    return context.t.classtable.classChangePage.k2;
                  case 3:
                    return context.t.classtable.classChangePage.k3;
                  case 4:
                    return context.t.classtable.classChangePage.k4;
                  case 5:
                    return context.t.classtable.classChangePage.k5;
                  case 6:
                    return context.t.classtable.classChangePage.k6;
                  case 7:
                    return context.t.classtable.classChangePage.k7;
                  default:
                    return "";
                }
              }

              String classChange = "";
              switch (toShow.type) {
                case ChangeType.change:
                  classChange += context.t.classtable.classChangePage
                      .changeClassMessage(
                        original_affected_weeks: toShow.originalClassRange[0]
                            .toString(),
                        week_char_original_week: toShow.originalClassRange[1]
                            .toString(),
                        original_class_range_start: weekChar(
                          toShow.originalWeek,
                        ),
                        original_class_range_end: originalAffectedWeeksStr,
                        new_affected_weeks_list_str:
                            (toShow.newClassroom ?? toShow.originalClassroom)
                                .toString(),
                        week_char_new_week: toShow.newClassRange[0].toString(),
                        new_class_range_start: toShow.newClassRange[1]
                            .toString(),
                        new_class_range_stop: weekChar(toShow.newWeek),
                        new_classroom: newAffectedWeeksListStr,
                      );
                  break;
                case ChangeType.patch:
                  classChange += context.t.classtable.classChangePage
                      .patchClassMessage(
                        new_affected_weeks_list_str: toShow.newClassroom
                            .toString(),
                        week_char_new_week: toShow.newClassRange[0].toString(),
                        new_class_range_start: toShow.newClassRange[1]
                            .toString(),
                        new_class_range_stop: weekChar(toShow.newWeek),
                        new_classroom: newAffectedWeeksListStr,
                      );
                  break;
                case ChangeType.stop:
                  classChange += context.t.classtable.classChangePage
                      .stopClassMessage(
                        original_affected_weeks: toShow.originalClassRange[0]
                            .toString(),
                        week_char_original_week: toShow.originalClassRange[1]
                            .toString(),
                        original_class_range_start: weekChar(
                          toShow.originalWeek,
                        ),
                        original_class_range_end: originalAffectedWeeksStr,
                      );
                  break;
              }

              return ListTile(
                title: Text(toShow.className),
                subtitle: Text(
                  context.t.classtable.classChangePage.classInfo(
                    class_code: classChanges[index].classCode,
                    class_number: classChanges[index].classNumber,
                    class_change: classChange.replaceAll(" ", ''),
                    teacher_change:
                        classChanges[index].type == ChangeType.change
                        ? '\n$teacherChange'
                        : '',
                  ),
                ),
              );
            },
          ).constrained(maxWidth: 600);
        },
      ).center(),
    );
  }
}
