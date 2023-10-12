// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/experiment/experiment_info_card.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';

class ExperimentListView extends StatelessWidget {
  final List<ExperimentData> data;
  final Jiffy now = Jiffy.now();

  ExperimentListView({
    super.key,
    required this.data,
  });

  int get sum {
    int score = 0;
    for (var i in data) {
      if (!i.score.contains("未录入")) score += int.parse(i.score);
    }
    return score;
  }

  List<ExperimentData> get done {
    List<ExperimentData> isNotFinished = List.from(data);
    isNotFinished.removeWhere(
      (element) =>
          !Jiffy.parseFromDateTime(element.time[1]).isSameOrBefore(now),
    );
    return isNotFinished
      ..sort(
        (a, b) =>
            a.time[1].microsecondsSinceEpoch - b.time[1].microsecondsSinceEpoch,
      );
  }

  List<ExperimentData> get unDone {
    List<ExperimentData> isNotFinished = List.from(data);
    isNotFinished.removeWhere(
      (element) => !Jiffy.parseFromDateTime(element.time[0]).isSameOrAfter(now),
    );
    return isNotFinished
      ..sort(
        (a, b) =>
            a.time[1].microsecondsSinceEpoch - b.time[1].microsecondsSinceEpoch,
      );
  }

  List<ExperimentData> get doing {
    List<ExperimentData> isNotFinished = List.from(data);
    isNotFinished.removeWhere(
      (element) => !now.isBetween(
        Jiffy.parseFromDateTime(element.time[0]),
        Jiffy.parseFromDateTime(element.time[1]),
      ),
    );
    return isNotFinished
      ..sort(
        (a, b) =>
            a.time[1].microsecondsSinceEpoch - b.time[1].microsecondsSinceEpoch,
      );
  }

  @override
  Widget build(BuildContext context) {
    return TimelineWidget(
      isTitle: [
        if (doing.isNotEmpty) ...[
          true,
          false,
        ],
        true,
        false,
        true,
        false,
        false
      ],
      children: [
        if (doing.isNotEmpty) ...[
          const TimelineTitle(title: "正在进行实验"),
          Column(
            children: List.generate(
              doing.length,
              (index) => ExperimentInfoCard(
                data: doing[index],
              ),
            ),
          ),
        ],
        const TimelineTitle(title: "未完成实验"),
        unDone.isNotEmpty
            ? Column(
                children: List.generate(
                  unDone.length,
                  (index) => ExperimentInfoCard(
                    data: unDone[index],
                  ),
                ),
              )
            : const TimelineTitle(
                title: "所有实验全部完成",
              ),
        const TimelineTitle(title: "已完成实验"),
        ExperimentInfoCard(
          title: "目前分数总和：$sum",
        ),
        done.isNotEmpty
            ? Column(
                children: List.generate(
                  done.length,
                  (index) => ExperimentInfoCard(
                    data: done[index],
                  ),
                ),
              )
            : const TimelineTitle(
                title: "目前你还没做一次实验",
              ),
      ],
    );
  }
}
