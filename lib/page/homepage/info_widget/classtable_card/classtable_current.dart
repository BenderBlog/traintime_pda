// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:timelines/timelines.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/page/homepage/refresh.dart';

class ClasstableCurrentTimeline extends StatelessWidget {
  const ClasstableCurrentTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return FixedTimeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
      ),
      builder: TimelineTileBuilder(
        itemCount: 3,
        contentsAlign: ContentsAlign.basic,
        contentsBuilder: (context, index) => switch (index) {
          0 => const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 8.0),
              child: ClasstableCurrentColumn()),
          1 => const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 8.0),
              child: ClasstableCurrentColumn(isArrangementMode: true)),
          _ => Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Obx(() {
                late String toShow;
                if (remaining <= 0) {
                  toShow = "之后没有日程了";
                } else {
                  toShow = "之后还有 $remaining 个日程";
                }
                return Text(
                  toShow,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }),
            ),
        },
        indicatorBuilder: (context, index) => Indicator.widget(
          position: switch (index) {
            0 => 0.05, // Current Class
            1 => 0.05, // Next Class
            _ => 0.50, // More Class
          },
          child: Icon(switch (index) {
            0 => Icons.timelapse_outlined, // Current Class
            1 => Icons.schedule_outlined, // Next Class
            _ => Icons.more_time_outlined, // More Class
          }),
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

          return Connector.solidLine(
            color: Theme.of(context).colorScheme.primary,
            thickness: 3,
          );
        },
        endConnectorBuilder: (context, index) {
          if (index >= 2) {
            return null;
          }

          if (index == 0 && isTomorrow.isTrue) {
            // Use dashedLine between today and tomorrow
            return Connector.dashedLine(
              color: Theme.of(context).colorScheme.primary,
              gap: 4,
              thickness: 3,
            );
          }

          return Connector.solidLine(
            color: Theme.of(context).colorScheme.primary,
            thickness: 3,
          );
        },
      ),
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
    return [
      Obx(() {
        late String text;
        if (arrangementState.value == ArrangementState.fetched) {
          if (isArrangementMode) {
            text = next.value?.name ?? "暂无进一步安排";
          } else {
            text = current.value?.name ?? "没有正在进行的日程";
          }
        } else if (arrangementState.value == ArrangementState.error) {
          text = "遇到错误";
        } else {
          text = "正在加载";
        }
        return Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ).alignment(Alignment.centerLeft).expanded();
      }),
      const SizedBox(height: 8.0),
      Obx(() {
        if (arrangementState.value == ArrangementState.fetched) {
          if (isArrangementMode) {
            return ClasstableCurrentListTile(homeArrangement: next.value);
          } else {
            return ClasstableCurrentListTile(homeArrangement: current.value);
          }
        } else {
          return Text(
            arrangementState.value == ArrangementState.error
                ? "日程获取失败"
                : "请耐心等待片刻",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }),
    ].toColumn(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class ClasstableCurrentListTile extends StatelessWidget {
  final HomeArrangement? homeArrangement;
  const ClasstableCurrentListTile({
    super.key,
    required this.homeArrangement,
  });

  @override
  Widget build(BuildContext context) {
    if (homeArrangement != null) {
      return [
        [
          Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 2),
          Text(
            homeArrangement!.teacher,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ].toRow(),
        [
          Icon(
            Icons.room,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 2),
          Text(
            homeArrangement!.place,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ].toRow(),
        [
          Icon(
            Icons.access_time_filled_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 2),
          Text(
            "${isTomorrow.isTrue ? "明天 " : ""}"
            "${Jiffy.parseFromDateTime(homeArrangement!.startTime).format(pattern: "HH:mm")}-"
            "${Jiffy.parseFromDateTime(homeArrangement!.endTime).format(pattern: "HH:mm")}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ].toRow(),
      ].toColumn();
    } else {
      return const SizedBox(height: 30.0);
    }
  }
}
