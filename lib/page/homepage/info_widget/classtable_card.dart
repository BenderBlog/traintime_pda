// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timelines/timelines.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

class ClassTableCard extends StatelessWidget {
  const ClassTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FixedTimeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
        ),
        builder: TimelineTileBuilder(
          itemCount: remaining.value > 0 ? 3 : 2,
          contentsAlign: ContentsAlign.basic,
          contentsBuilder: (context, timelineNodeIndex) =>
              switch (timelineNodeIndex) {
            0 => const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 10.0),
                child: ClasstableCurrentColumn()),
            1 => const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 10.0),
                child: ClasstableCurrentColumn(isArrangementMode: true)),
            _ => Padding(
                padding: const EdgeInsets.fromLTRB(5, 4, 0, 10.0),
                child: List<Widget>.generate(remaining.value, (index) {
                  var textStyle = TextStyle(
                    height: 1.1,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.primary,
                  );
                  var arrangementIndex =
                      index + arrangement.length - remaining.value;

                  return [
                    Text(
                      Jiffy.parseFromDateTime(
                              arrangement[arrangementIndex].startTime)
                          .format(pattern: "HH:mm"),
                      style: textStyle,
                    ).alignment(Alignment.topLeft),
                    Text(
                      arrangement[arrangementIndex].name,
                      style: textStyle,
                    ).alignment(Alignment.centerLeft).expanded(),
                  ].toRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    separator: const SizedBox(width: 8.0),
                  );
                }).toColumn(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  separator: const SizedBox(height: 4.0),
                ),
              ),
          },
          indicatorBuilder: (context, index) => Indicator.widget(
            position: 0,
            child: Icon(
              switch (index) {
                0 => Icons.timelapse_outlined, // Current Class
                1 => Icons.schedule_outlined, // Next Class
                _ => Icons.more_time_outlined, // More Class
              },
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          startConnectorBuilder: (context, index) {
            if (index == 0) {
              return null;
            }

            if (index == 1 && isTomorrow.isTrue) {
              // Use dashedLine between today and tomorrow
              return Connector.dashedLine(
                color: Theme.of(context).colorScheme.primary,
                gap: 4,
                thickness: 3,
              );
            }

            if (index > 2) {
              return Connector.solidLine(
                color: Theme.of(context).colorScheme.primary,
                thickness: 2,
              );
            }

            return Connector.solidLine(
              color: Theme.of(context).colorScheme.primary,
              thickness: 3,
            );
          },
          endConnectorBuilder: (context, index) {
            if (index == 0 && isTomorrow.isTrue) {
              // Use dashedLine between today and tomorrow
              return Connector.dashedLine(
                color: Theme.of(context).colorScheme.primary,
                gap: 4,
                thickness: 3,
              );
            }

            if (index >= 2) {
              return Connector.solidLine(
                color: Theme.of(context).colorScheme.primary,
                thickness: 2,
              );
            }

            return Connector.solidLine(
              color: Theme.of(context).colorScheme.primary,
              thickness: 3,
            );
          },
        ),
      ),
    )
        .paddingDirectional(horizontal: 20, vertical: 14)
        .withHomeCardStyle(Theme.of(context).colorScheme.secondary)
        .gestures(
      onTap: () {
        final c = Get.find<ClassTableController>();
        switch (c.state) {
          case ClassTableState.fetched:
            context.pushReplacement(LayoutBuilder(
              builder: (context, constraints) => ClassTableWindow(
                parentContext: context,
                currentWeek: c.getCurrentWeek(updateTime),
                constraints: constraints,
              ),
            ));
          case ClassTableState.error:
            showToast(context: context, msg: "遇到错误：${c.error}");
          case ClassTableState.fetching:
          case ClassTableState.none:
            showToast(context: context, msg: "正在获取课表");
        }
      },
    );
  }
}

class ClasstableCurrentColumn extends StatelessWidget {
  /// Check whether it is the second element.
  /// For showing the next / following.
  final bool isArrangementMode;

  const ClasstableCurrentColumn({
    super.key,
    this.isArrangementMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      HomeArrangement? homeArrangement;
      if (arrangementState.value == ArrangementState.fetched) {
        homeArrangement = isArrangementMode ? next.value : current.value;
      }

      late String timeText;
      if (isArrangementMode) {
        timeText = isTomorrow.isTrue ? "明天 " : "稍后 ";
      } else {
        timeText = "当前 ";
      }
      if (homeArrangement != null) {
        timeText +=
            "${Jiffy.parseFromDateTime(homeArrangement.startTime).format(pattern: "HH:mm")} - "
            "${Jiffy.parseFromDateTime(homeArrangement.endTime).format(pattern: "HH:mm")}";
      }

      late String infoText;
      if (homeArrangement != null) {
        infoText = homeArrangement.name;
      } else if (arrangementState.value == ArrangementState.error) {
        infoText = "遇到错误";
      } else if (arrangementState.value == ArrangementState.fetching) {
        infoText = "正在加载";
      } else {
        infoText = "暂无日程";
      }

      return [
        Text(
          timeText,
          style: TextStyle(
            height: 1.1,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ).padding(top: 5).alignment(Alignment.bottomLeft),
        Text(
          infoText,
          style: TextStyle(
            height: 1.1,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.primary,
          ),
        ).alignment(Alignment.centerLeft).expanded(),
        if (homeArrangement != null)
          ClasstableCurrentListTile(homeArrangement: homeArrangement),
      ].toColumn(separator: const SizedBox(height: 4.0));
    });
  }
}

class ClasstableCurrentListTile extends StatelessWidget {
  final HomeArrangement homeArrangement;

  const ClasstableCurrentListTile({
    super.key,
    required this.homeArrangement,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    if (homeArrangement.place != null) {
      items.add(createIconText(context, Icons.room, homeArrangement.place!));
    }

    if (homeArrangement.seat != null) {
      items.add(createIconText(context, Icons.chair, homeArrangement.seat!.toString()));
    }

    if (homeArrangement.teacher != null) {
      items.add(createIconText(context, Icons.person, homeArrangement.teacher!));
    }

    return items.toRow(separator: const SizedBox(width: 6));
  }

  static Widget createIconText(BuildContext context, IconData icon, String text) {
    return [
      Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 18,
      ),
      Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      )
    ].toRow(separator: const SizedBox(width: 2));
  }
}
