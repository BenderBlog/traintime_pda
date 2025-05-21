// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';

class ExamInfoCard extends StatelessWidget {
  final Subject? toUse;
  final String? title;

  const ExamInfoCard({
    super.key,
    this.toUse,
    this.title,
  }) : assert(toUse != null || title != null);

  @override
  Widget build(BuildContext context) {
    return toUse != null
        ? ReXCard(
            title: Text(toUse!.subject),
            remaining: [
              ReXCardRemaining(toUse!.type),
            ],
            bottomRow: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                InformationWithIcon(
                  icon: Icons.access_time_filled_rounded,
                  text: toUse!.time,
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    InformationWithIcon(
                      icon: Icons.room,
                      text: toUse!.place,
                    ).flexible(),
                    if (toUse!.seat != null)
                      InformationWithIcon(
                        icon: Icons.chair,
                        text: toUse!.seat.toString(),
                      ).flexible(),
                  ],
                ),
              ],
            ),
          )
        : Text(
            title!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).padding(all: 14).card(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              elevation: 0,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            );
  }
}
