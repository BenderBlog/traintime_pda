// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail_data.dart';
import 'package:watermeter/page/classtable/arrangement_detail/custom_list_tile.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'package:watermeter/generated/translations.g.dart';

/// A dialog/card shows the class detail / time arrangement.
class ClassDetailCard extends StatelessWidget {
  final ArrangementDetailItem item;
  final int currentWeek;
  final int semesterWeekCount;
  const ClassDetailCard({
    super.key,
    required this.item,
    required this.currentWeek,
    required this.semesterWeekCount,
  });

  /// A doc shows the week info of the class, whether the class /
  /// time arrangement occurs in this week.
  Widget weekDoc({required int index}) {
    bool isOccupied = true;
    final infoColor = item.color;
    if (index >= (item.weekList?.length ?? 0) || !item.weekList![index]) {
      isOccupied = false;
    }
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? infoColor.shade200 : null,
          borderRadius: const BorderRadius.all(Radius.circular(100.0)),
          border: index == currentWeek
              ? Border.all(width: 2, color: infoColor)
              : null,
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: TextStyle(
              color: isOccupied
                  ? infoColor.shade900
                  : infoColor.shade400.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final infoColor = item.color;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360.0),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        elevation: 0,
        color: infoColor.shade100,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${item.name}"
                "${item.code != null && item.number != null ? "\n${item.code} | ${context.t.classtable.courseDetailCard.classNumberString(number: '${item.number}')}" : ""}",
                style: TextStyle(
                  color: infoColor.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    child: CustomListTile(
                      icon: Icons.person,
                      str:
                          item.teacher ??
                          context.t.classtable.courseDetailCard.unknownTeacher,
                      infoColor: infoColor,
                    ),
                  ),
                  Flexible(
                    child: CustomListTile(
                      icon: Icons.room,
                      str:
                          item.classroom ??
                          context.t.classtable.courseDetailCard.unknownPlace,
                      infoColor: infoColor,
                    ),
                  ),
                ],
              ),
              CustomListTile(
                icon: Icons.access_time_filled_outlined,
                str:
                    "${getWeekString(context, item.weekday! - 1)}"
                    "${context.t.classtable.courseDetailCard.classPeriod(start: '${item.startPeriod}', stop: '${item.stopPeriod}')} "
                    "${DateFormat('HH:mm').format(item.dateRanges.first.start)}-${DateFormat('HH:mm').format(item.dateRanges.first.end)}",
                infoColor: infoColor,
              ),

              /// These gridview can show when this arrangment occurs in weeks.
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GridView.extent(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  maxCrossAxisExtent: 30,
                  children: List.generate(
                    semesterWeekCount,
                    (index) => weekDoc(index: index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
