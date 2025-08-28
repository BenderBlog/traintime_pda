// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/classtable/arrangement_detail/custom_list_tile.dart';

/// A dialog/card shows the exam detail.
class ExamDetailCard extends StatelessWidget {
  final Subject subject;
  final MaterialColor infoColor;
  const ExamDetailCard({
    super.key,
    required this.subject,
    required this.infoColor,
  });

  @override
  Widget build(BuildContext context) {
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
                "${subject.subject}${subject.type}",
                style: TextStyle(
                  color: infoColor.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              [
                CustomListTile(
                  icon: Icons.room,
                  str: subject.place,
                  infoColor: infoColor,
                ).flexible(),
                if (subject.seat != null)
                  CustomListTile(
                    icon: Icons.chair,
                    str: subject.seat.toString(),
                    infoColor: infoColor,
                  ).flexible(),
              ].toRow(),
              CustomListTile(
                icon: Icons.access_time_filled_outlined,
                str: subject.time,
                infoColor: infoColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
