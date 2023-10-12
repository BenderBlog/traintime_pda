// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/widget.dart';

class ExperimentInfoCard extends StatelessWidget {
  final ExperimentData? data;
  final String? title;
  const ExperimentInfoCard({
    super.key,
    this.data,
    this.title,
  }) : assert(data != null || title != null);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: data != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        data!.name,
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TagsBoxes(
                        text: data!.score,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 5,
                      ),
                      informationWithIcon(
                        Icons.access_time_filled_rounded,
                        "${data!.date} ${data!.timeStr}",
                        context,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 1,
                            child: informationWithIcon(
                              Icons.room,
                              data!.classroom,
                              context,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: informationWithIcon(
                              Icons.person,
                              data!.teacher,
                              context,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: informationWithIcon(
                              Icons.book,
                              data!.reference,
                              context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Text(
                title!,
                textScaleFactor: 1.1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
