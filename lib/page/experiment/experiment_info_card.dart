// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';

class ExperimentInfoCard extends StatelessWidget {
  final ExperimentData? data;
  final String? title;
  const ExperimentInfoCard({super.key, this.data, this.title})
    : assert(data != null || title != null);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (data != null) {
          return ReXCard(
            title: Text(data!.name),
            remaining: [
              if (data!.score != null) ReXCardRemaining(data!.score!),
            ],
            bottomRow: Column(
              children: [
                Builder(
                  builder: (context) {
                    final dateFormatter = DateFormat("yyyy-MM-dd");
                    final timeFormatter = DateFormat("HH:mm");

                    return InformationWithIcon(
                      icon: Icons.access_time_filled_rounded,
                      text: data!.timeRanges
                          .map<String>((timeRange) {
                            final firstDate = timeRange.$1;
                            final secondDate = timeRange.$2;
                            final dateStr = dateFormatter.format(firstDate);
                            final startTimeStr = timeFormatter.format(
                              firstDate,
                            );
                            final endTimeStr = timeFormatter.format(secondDate);
                            return "$dateStr $startTimeStr-$endTimeStr";
                          })
                          .join("\n"),
                    );
                  },
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: 2,
                      child: InformationWithIcon(
                        icon: Icons.room,
                        text: data!.classroom,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InformationWithIcon(
                        icon: Icons.person,
                        text: data!.teacher,
                      ),
                    ),
                    // if (data!.reference?.isNotEmpty ?? false)
                    //   Expanded(
                    //     flex: 1,
                    //     child: InformationWithIcon(
                    //       icon: Icons.book,
                    //       text: data!.reference!,
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 0,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Text(
                title!,
                textScaler: const TextScaler.linear(1.1),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          );
        }
      },
    );
  }
}
