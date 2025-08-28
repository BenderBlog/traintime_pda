// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/page/experiment/experiment_info_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';

class ExperimentWindow extends StatefulWidget {
  const ExperimentWindow({super.key});

  @override
  State<ExperimentWindow> createState() => _ExperimentWindowState();
}

class _ExperimentWindowState extends State<ExperimentWindow> {
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "experiment.title")),
      ),
      body: GetBuilder<ExperimentController>(
        builder: (controller) {
          if (controller.status == ExperimentStatus.fetched ||
              controller.status == ExperimentStatus.cache) {
            var doing = controller.doing(now);
            var unDone = controller.isNotFinished(now);
            var done = controller.isFinished(now);
            return TimelineWidget(
              isTitle: [
                if (doing.isNotEmpty) ...[true, false],
                true,
                false,
                true,
                false,
                false,
              ],
              children: [
                if (doing.isNotEmpty) ...[
                  TimelineTitle(
                    title: FlutterI18n.translate(context, "experiment.ongoing"),
                  ),
                  Column(
                    children: List.generate(
                      doing.length,
                      (index) => ExperimentInfoCard(data: doing[index]),
                    ),
                  ),
                ],
                TimelineTitle(
                  title: FlutterI18n.translate(
                    context,
                    "experiment.not_finished",
                  ),
                ),
                unDone.isNotEmpty
                    ? Column(
                        children: List.generate(
                          unDone.length,
                          (index) => ExperimentInfoCard(data: unDone[index]),
                        ),
                      )
                    : TimelineTitle(
                        title: FlutterI18n.translate(
                          context,
                          "experiment.all_finished",
                        ),
                      ),
                TimelineTitle(
                  title: FlutterI18n.translate(context, "experiment.finished"),
                ),
                ExperimentInfoCard(
                  title: FlutterI18n.translate(
                    context,
                    "experiment.score_sum",
                    translationParams: {"sum": controller.sum.toString()},
                  ),
                ),
                done.isNotEmpty
                    ? Column(
                        children: List.generate(
                          done.length,
                          (index) => ExperimentInfoCard(data: done[index]),
                        ),
                      )
                    : TimelineTitle(
                        title: FlutterI18n.translate(
                          context,
                          "experiment.none_finished",
                        ),
                      ),
              ],
            ).safeArea();
          } else if (controller.status == ExperimentStatus.error) {
            return ReloadWidget(
              function: controller.get,
              errorStatus: FlutterI18n.translate(context, controller.error),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
