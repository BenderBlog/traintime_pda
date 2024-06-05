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
                padding: EdgeInsets.fromLTRB(5, 0.5, 0, 10.0),
                child: ClassTableCardItem(
                    displayMode: ClassTableCardItemDisplayMode.current)),
            1 => const Padding(
                padding: EdgeInsets.fromLTRB(5, 0.5, 0, 10.0),
                child: ClassTableCardItem(
                    displayMode: ClassTableCardItemDisplayMode.next)),
            _ => const Padding(
                padding: EdgeInsets.fromLTRB(5, 1.5, 0, 10.0),
                child: ClassTableCardItem(
                    displayMode: ClassTableCardItemDisplayMode.more)),
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

enum ClassTableCardItemDisplayMode {
  current,
  next,
  more,
}

class ClassTableCardItem extends StatelessWidget {
  final ClassTableCardItemDisplayMode displayMode;

  const ClassTableCardItem({
    super.key,
    required this.displayMode,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<Widget> columns = [
        Text(
          getTimeText(),
          style: TextStyle(
            height: 1.1,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ).padding(top: 5).alignment(Alignment.bottomLeft)
      ];

      switch (displayMode) {
        case ClassTableCardItemDisplayMode.current:
        case ClassTableCardItemDisplayMode.next:
          columns.addAll(getCurrentOrNextArrangementColumns(context));
        case ClassTableCardItemDisplayMode.more:
          columns.addAll(getMoreArrangementsColumns(context));
        default:
          throw Exception("Unknown displayMode: $displayMode");
      }

      return columns.toColumn(separator: const SizedBox(height: 4.0));
    });
  }

  HomeArrangement? getDisplayArrangement() {
    switch (displayMode) {
      case ClassTableCardItemDisplayMode.current:
        return current.value;
      case ClassTableCardItemDisplayMode.next:
        return next.value;
      default:
        return null;
    }
  }

  String getTimeText() {
    String timeText = switch (displayMode) {
      ClassTableCardItemDisplayMode.current => "当前",
      ClassTableCardItemDisplayMode.next => isTomorrow.isTrue ? "明天" : "稍后",
      ClassTableCardItemDisplayMode.more => "更多",
      _ => "未知",
    };

    HomeArrangement? arr = getDisplayArrangement();
    if (arr != null) {
      timeText += " "
          "${Jiffy.parseFromDateTime(arr.startTime).format(pattern: "HH:mm")} - "
          "${Jiffy.parseFromDateTime(arr.endTime).format(pattern: "HH:mm")}";
    }
    return timeText;
  }

  List<Widget> getCurrentOrNextArrangementColumns(BuildContext context) {
    HomeArrangement? arr = getDisplayArrangement();

    late String infoText;
    if (arr != null) {
      infoText = arr.name;
    } else if (arrangementState.value == ArrangementState.error) {
      infoText = "遇到错误";
    } else if (arrangementState.value == ArrangementState.fetching) {
      infoText = "正在加载";
    } else {
      infoText = "暂无日程";
    }

    return [
      Text(
        infoText,
        style: TextStyle(
          height: 1.1,
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).colorScheme.primary,
        ),
      ).alignment(Alignment.centerLeft).expanded(),
      if (arr != null) ClassTableCardArrangementDetail(displayArrangement: arr),
    ];
  }

  List<Widget> getMoreArrangementsColumns(BuildContext context) {
    return List<Widget>.generate(remaining.value, (i) {
      var index = i + arrangement.length - remaining.value;

      return [
        Text(
          Jiffy.parseFromDateTime(arrangement[index].startTime).format(pattern: "HH:mm"),
          style: TextStyle(
            height: 1.2,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ).alignment(Alignment.topLeft),
        Text(
          arrangement[index].name,
          style: TextStyle(
            height: 1.1,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.primary,
          ),
        ).alignment(Alignment.topLeft).expanded(),
      ].toRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        separator: const SizedBox(width: 8.0),
      );
    });
  }
}

class ClassTableCardArrangementDetail extends StatelessWidget {
  final HomeArrangement displayArrangement;

  const ClassTableCardArrangementDetail({
    super.key,
    required this.displayArrangement,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    if (displayArrangement.place != null) {
      items.add(createIconText(context, Icons.room, displayArrangement.place!));
    }

    if (displayArrangement.seat != null) {
      items.add(createIconText(
          context, Icons.chair, displayArrangement.seat!.toString()));
    }

    if (displayArrangement.teacher != null) {
      items.add(
          createIconText(context, Icons.person, displayArrangement.teacher!));
    }

    return items.toRow(separator: const SizedBox(width: 6));
  }

  static Widget createIconText(
      BuildContext context, IconData icon, String text) {
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
