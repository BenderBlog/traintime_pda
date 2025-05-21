// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';

/// A new page to show the class changed.
/// Shows a list of [ClassDetail] which do not have the time arrangement.

class ClassChangeList extends StatelessWidget {
  final List<ClassChange> classChanges;
  const ClassChangeList({
    super.key,
    required this.classChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(
          context,
          "classtable.class_change_page.title",
        )),
      ),
      body: Builder(builder: (context) {
        if (classChanges.isEmpty) {
          return EmptyListView(
            type: Type.reading,
            text: FlutterI18n.translate(
              context,
              "classtable.class_change_page.empty_message",
            ),
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
                  teacherChange += FlutterI18n.translate(
                      context, "classtable.class_change_page.teacher_change",
                      translationParams: {
                        "previous_teacher":
                            classChanges[index].originalTeacher ??
                                FlutterI18n.translate(context, "no_info"),
                        "new_teacher": classChanges[index].originalNewTeacher!,
                      });
                } else {
                  teacherChange += FlutterI18n.translate(
                    context,
                    "classtable.class_change_page.no_teacher_change",
                  );
                }
              }

              String originalAffectedWeeksStr = "";
              for (int i = 0;
                  i < toShow.originalAffectedWeeksList.length;
                  ++i) {
                originalAffectedWeeksStr +=
                    (toShow.originalAffectedWeeksList[i] + 1).toString();
                if (i + 1 != toShow.originalAffectedWeeksList.length) {
                  originalAffectedWeeksStr += ", ";
                }
              }

              String newAffectedWeeksListStr = "";
              for (int i = 0; i < toShow.newAffectedWeeksList.length; ++i) {
                newAffectedWeeksListStr +=
                    (toShow.newAffectedWeeksList[i] + 1).toString();
                if (i + 1 != toShow.newAffectedWeeksList.length) {
                  newAffectedWeeksListStr += ", ";
                }
              }

              String weekChar(int? week) => FlutterI18n.translate(
                    context,
                    week != null ? "classtable.class_change_page.$week" : "",
                  );

              String classChange = "";
              switch (toShow.type) {
                case ChangeType.change:
                  classChange += FlutterI18n.translate(context,
                      "classtable.class_change_page.change_class_message",
                      translationParams: {
                        "originalAffectedWeeks": originalAffectedWeeksStr,
                        "weekChar_originalWeek": weekChar(toShow.originalWeek),
                        "originalClassRangeStart":
                            toShow.originalClassRange[0].toString(),
                        "originalClassRangeEnd":
                            toShow.originalClassRange[1].toString(),
                        "newAffectedWeeksListStr": newAffectedWeeksListStr,
                        "weekChar_newWeek": weekChar(toShow.newWeek),
                        "newClassRangeStart":
                            toShow.newClassRange[0].toString(),
                        "newClassRangeStop": toShow.newClassRange[1].toString(),
                        "newClassroom":
                            (toShow.newClassroom ?? toShow.originalClassroom)
                                .toString(),
                      });
                  break;
                case ChangeType.patch:
                  classChange += FlutterI18n.translate(context,
                      "classtable.class_change_page.patch_class_message",
                      translationParams: {
                        "newAffectedWeeksListStr": newAffectedWeeksListStr,
                        "weekChar_newWeek": weekChar(toShow.newWeek),
                        "newClassRangeStart":
                            toShow.newClassRange[0].toString(),
                        "newClassRangeStop": toShow.newClassRange[1].toString(),
                        "newClassroom": toShow.newClassroom.toString(),
                      });
                  break;
                case ChangeType.stop:
                  classChange += FlutterI18n.translate(context,
                      "classtable.class_change_page.stop_class_message",
                      translationParams: {
                        "originalAffectedWeeks": originalAffectedWeeksStr,
                        "weekChar_originalWeek": weekChar(toShow.originalWeek),
                        "originalClassRangeStart":
                            toShow.originalClassRange[0].toString(),
                        "originalClassRangeEnd":
                            toShow.originalClassRange[1].toString(),
                      });
                  break;
              }

              return ListTile(
                title: Text(toShow.className),
                subtitle: Text(
                  FlutterI18n.translate(
                      context, "classtable.class_change_page.class_info",
                      translationParams: {
                        "classCode": classChanges[index].classCode,
                        "classNumber": classChanges[index].classNumber,
                        "classChange": classChange.replaceAll(" ", ''),
                        "teacherChange":
                            classChanges[index].type == ChangeType.change
                                ? "\n$teacherChange"
                                : "",
                      }),
                ),
              );
            }).constrained(maxWidth: 600);
      }).center(),
    );
  }
}
