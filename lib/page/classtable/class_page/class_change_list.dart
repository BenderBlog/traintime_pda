// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/generated/l10n.dart';

/// A new page to show the class changed.
/// Shows a list of [ClassDetail] which do not have the time arrangement.

class ClassChangeList extends StatelessWidget {
  final List<ClassChange> classChanges;
  const ClassChangeList({super.key, required this.classChanges});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context)!.classtableClassChangePageTitle),
      ),
      body: Builder(
        builder: (context) {
          if (classChanges.isEmpty) {
            return EmptyListView(
              type: EmptyListViewType.defaultimg,
              text: I18n.of(context)!.classtableClassChangePageEmptyMessage,
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
                  teacherChange += I18n.of(context)!
                      .classtableClassChangePageTeacherChange(
                        classChanges[index].originalTeacher ??
                            I18n.of(context)!.noInfo,
                        classChanges[index].originalNewTeacher!,
                      );
                } else {
                  teacherChange += I18n.of(
                    context,
                  )!.classtableClassChangePageNoTeacherChange;
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
                    return I18n.of(context)!.classtableClassChangePage1;
                  case 2:
                    return I18n.of(context)!.classtableClassChangePage2;
                  case 3:
                    return I18n.of(context)!.classtableClassChangePage3;
                  case 4:
                    return I18n.of(context)!.classtableClassChangePage4;
                  case 5:
                    return I18n.of(context)!.classtableClassChangePage5;
                  case 6:
                    return I18n.of(context)!.classtableClassChangePage6;
                  case 7:
                    return I18n.of(context)!.classtableClassChangePage7;
                  default:
                    return "";
                }
              }

              String classChange = "";
              switch (toShow.type) {
                case ChangeType.change:
                  classChange += I18n.of(context)!
                      .classtableClassChangePageChangeClassMessage(
                        toShow.originalClassRange[0].toString(),
                        toShow.originalClassRange[1].toString(),
                        weekChar(toShow.originalWeek),
                        originalAffectedWeeksStr,
                        (toShow.newClassroom ?? toShow.originalClassroom)
                            .toString(),
                        toShow.newClassRange[0].toString(),
                        toShow.newClassRange[1].toString(),
                        weekChar(toShow.newWeek),
                        newAffectedWeeksListStr,
                      );
                  break;
                case ChangeType.patch:
                  classChange += I18n.of(context)!
                      .classtableClassChangePagePatchClassMessage(
                        toShow.newClassroom.toString(),
                        toShow.newClassRange[0].toString(),
                        toShow.newClassRange[1].toString(),
                        weekChar(toShow.newWeek),
                        newAffectedWeeksListStr,
                      );
                  break;
                case ChangeType.stop:
                  classChange += I18n.of(context)!
                      .classtableClassChangePageStopClassMessage(
                        toShow.originalClassRange[0].toString(),
                        toShow.originalClassRange[1].toString(),
                        weekChar(toShow.originalWeek),
                        originalAffectedWeeksStr,
                      );
                  break;
              }

              return ListTile(
                title: Text(toShow.className),
                subtitle: Text(
                  I18n.of(context)!.classtableClassChangePageClassInfo(
                    classChanges[index].classCode,
                    classChanges[index].classNumber,
                    classChange.replaceAll(" ", ''),
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
