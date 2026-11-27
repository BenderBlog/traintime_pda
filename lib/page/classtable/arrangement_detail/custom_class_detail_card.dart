// Copyright 2026 Hazuki Keatsu.
// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail_data.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/classtable/arrangement_detail/custom_list_tile.dart';

class CustomClassDetailCard extends StatelessWidget {
  final ArrangementDetailItem item;

  const CustomClassDetailCard({super.key, required this.item});

  String _dateText(DateTimeRange range) =>
      DateFormat('yyyy-MM-dd').format(range.start);

  String _timeText(DateTimeRange range) =>
      '${DateFormat('HH:mm').format(range.start)}-${DateFormat('HH:mm').format(range.end)}';

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
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: infoColor.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5),
              CustomListTile(
                icon: Icons.person,
                str:
                    item.teacher ??
                    context.t.classtable.courseDetailCard.unknownTeacher,
                infoColor: infoColor,
              ),
              CustomListTile(
                icon: Icons.room,
                str:
                    item.classroom ??
                    context.t.classtable.courseDetailCard.unknownPlace,
                infoColor: infoColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.access_time_filled_outlined,
                      color: infoColor.shade900,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: item.dateRanges
                            .map(
                              (range) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                child: _TimeRangeRow(
                                  dateText: _dateText(range),
                                  timeText: _timeText(range),
                                  isBold:
                                      range.start ==
                                      item.selectedDateRange?.start,
                                  infoColor: infoColor,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        ArrangementDetailAction(
                          customClassId: item.customClassId!,
                          customTimeRangeId: item.customTimeRangeId,
                          type: CustomCourseActionType.edit,
                        ),
                      );
                    },
                    child: Text(
                      context.t.classtable.courseDetailCard.edit,
                      style: TextStyle(color: infoColor.shade900),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      bool? isContinue = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            context.t.classtable.courseDetailCard.deleteTitle,
                          ),
                          content: Text(
                            context
                                .t
                                .classtable
                                .courseDetailCard
                                .deleteContentSingle,
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.t.common.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.t.common.confirm),
                            ),
                          ],
                        ),
                      );
                      if (context.mounted && isContinue == true) {
                        Navigator.of(context).pop(
                          ArrangementDetailAction(
                            customClassId: item.customClassId!,
                            customTimeRangeId: item.customTimeRangeId,
                            type: CustomCourseActionType.deleteOne,
                          ),
                        );
                      }
                    },
                    child: Text(
                      context.t.classtable.courseDetailCard.deleteSingle,
                      style: TextStyle(color: infoColor.shade900),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      bool? isContinue = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            context.t.classtable.courseDetailCard.deleteTitle,
                          ),
                          content: Text(
                            context.t.classtable.courseDetailCard.deleteContent,
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.t.common.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.t.common.confirm),
                            ),
                          ],
                        ),
                      );
                      if (context.mounted && isContinue == true) {
                        Navigator.of(context).pop(
                          ArrangementDetailAction(
                            customClassId: item.customClassId!,
                            type: CustomCourseActionType.deleteAll,
                          ),
                        );
                      }
                    },
                    child: Text(
                      context.t.classtable.courseDetailCard.deleteAll,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeRow extends StatelessWidget {
  final String dateText;
  final String timeText;
  final bool isBold;
  final MaterialColor infoColor;

  const _TimeRangeRow({
    required this.dateText,
    required this.timeText,
    required this.isBold,
    required this.infoColor,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: infoColor.shade900,
      fontSize: 16,
      fontWeight: isBold ? FontWeight.bold : null,
    );
    return Row(
      children: [
        SizedBox(width: 100, child: Text(dateText, style: textStyle)),
        Text(timeText, style: textStyle),
      ],
    );
  }
}
