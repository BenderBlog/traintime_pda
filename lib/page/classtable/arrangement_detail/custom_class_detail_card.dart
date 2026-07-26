// Copyright 2026 Hazuki Keatsu.
// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/classtable/arrangement_detail/course_detail_card.dart';
import 'package:watermeter/generated/l10n.dart';

class CustomClassDetailCard extends StatelessWidget {
  final CustomClass customClass;
  final CustomClassTimeRange timeRange;
  final MaterialColor infoColor;

  const CustomClassDetailCard({
    super.key,
    required this.customClass,
    required this.timeRange,
    required this.infoColor,
  });

  String _dateText(CustomClassTimeRange range) =>
      DateFormat('yyyy-MM-dd').format(range.startTime);

  String _timeText(CustomClassTimeRange range) =>
      '${DateFormat('HH:mm').format(range.startTime)}-${DateFormat('HH:mm').format(range.endTime)}';

  @override
  Widget build(BuildContext context) {
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
                customClass.name,
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
                    customClass.teacher ??
                    I18n.of(context)!.classtableCourseDetailCardUnknownTeacher,
                infoColor: infoColor,
              ),
              CustomListTile(
                icon: Icons.room,
                str:
                    customClass.classroom ??
                    I18n.of(context)!.classtableCourseDetailCardUnknownPlace,
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
                        children: customClass.timeRanges
                            .map(
                              (range) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 1),
                                child: _TimeRangeRow(
                                  dateText: _dateText(range),
                                  timeText: _timeText(range),
                                  isBold: range.id == timeRange.id,
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
                      Navigator.of(
                        context,
                      ).pop((customClass.id, timeRange.id, 'edit'));
                    },
                    child: Text(
                      I18n.of(context)!.classtableCourseDetailCardEdit,
                      style: TextStyle(color: infoColor.shade900),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      bool? isContinue = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            I18n.of(context)!.classtableCourseDetailCardDeleteTitle,
                          ),
                          content: Text(
                            I18n.of(context)!.classtableCourseDetailCardDeleteContentSingle,
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
                              child: Text(
                                I18n.of(context)!.cancel,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                I18n.of(context)!.confirm,
                              ),
                            ),
                          ],
                        ),
                      );
                      if (context.mounted && isContinue == true) {
                        Navigator.of(
                          context,
                        ).pop((customClass.id, timeRange.id, 'delete_one'));
                      }
                    },
                    child: Text(
                      I18n.of(context)!.classtableCourseDetailCardDeleteSingle,
                      style: TextStyle(color: infoColor.shade900),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      bool? isContinue = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            I18n.of(context)!.classtableCourseDetailCardDeleteTitle,
                          ),
                          content: Text(
                            I18n.of(context)!.classtableCourseDetailCardDeleteContent,
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
                              child: Text(
                                I18n.of(context)!.cancel,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                I18n.of(context)!.confirm,
                              ),
                            ),
                          ],
                        ),
                      );
                      if (context.mounted && isContinue == true) {
                        Navigator.of(
                          context,
                        ).pop((customClass.id, null, 'delete_all'));
                      }
                    },
                    child: Text(
                      I18n.of(context)!.classtableCourseDetailCardDeleteAll,
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
