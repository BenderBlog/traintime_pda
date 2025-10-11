// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/page/experiment/experiment_info_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class ExperimentWindow extends StatefulWidget {
  const ExperimentWindow({super.key});

  @override
  State<ExperimentWindow> createState() => _ExperimentWindowState();
}

class _ExperimentWindowState extends State<ExperimentWindow> {
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExperimentController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "experiment.title")),
          actions: [
            if (!offline &&
                    (controller.physicsStatus == ExperimentStatus.fetched ||
                        controller.physicsStatus == ExperimentStatus.cache) ||
                (controller.otherStatus == ExperimentStatus.fetched ||
                    controller.otherStatus == ExperimentStatus.cache))
              IconButton(
                icon: const Icon(Icons.update),
                onPressed: () => controller.get().then((value) {
                  controller.update();
                  updateCurrentData();
                }),
              ),
          ],
        ),
        body: Builder(
          builder: (context) {
            if ((controller.physicsStatus == ExperimentStatus.fetched ||
                    controller.physicsStatus == ExperimentStatus.cache) ||
                (controller.otherStatus == ExperimentStatus.fetched ||
                    controller.otherStatus == ExperimentStatus.cache)) {
              /// Show cache notice
              if (controller.physicsStatus == ExperimentStatus.cache ||
                  controller.otherStatus == ExperimentStatus.cache) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "experiment.cache_hint",
                    translationParams: {
                      "info": [
                        if (controller.physicsStatus == ExperimentStatus.cache)
                          FlutterI18n.translate(
                            context,
                            "experiment.physics_experiment",
                          ),
                        if (controller.otherStatus == ExperimentStatus.cache)
                          FlutterI18n.translate(
                            context,
                            "experiment.other_experiment",
                          ),
                      ].join("; "),
                    },
                  ),
                );
              }

              var doing = controller.doing(now);
              var unDone = controller.isNotStarted(now);
              var done = controller.isFinished(now);
              return TimelineWidget(
                isTitle: [
                  if (controller.physicsStatus == ExperimentStatus.error) false,
                  if (controller.otherStatus == ExperimentStatus.error) false,
                  if (doing.isNotEmpty) ...[true, false],
                  true,
                  false,
                  true,
                  // false,
                  false,
                ],
                children: [
                  if (controller.physicsStatus == ExperimentStatus.error)
                    ExperimentInfoCard(
                      title: FlutterI18n.translate(
                        context,
                        "experiment.error_physics",
                        translationParams: {
                          "info": FlutterI18n.translate(
                            context,
                            controller.physicsStatusError,
                          ),
                        },
                      ),
                    ),
                  if (controller.otherStatus == ExperimentStatus.error)
                    ExperimentInfoCard(
                      title: FlutterI18n.translate(
                        context,
                        "experiment.error_other",
                        translationParams: {
                          "info": FlutterI18n.translate(
                            context,
                            controller.otherStatusError,
                          ),
                        },
                      ),
                    ),
                  if (doing.isNotEmpty) ...[
                    TimelineTitle(
                      title: FlutterI18n.translate(
                        context,
                        "experiment.ongoing",
                      ),
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
                    title: FlutterI18n.translate(
                      context,
                      "experiment.finished",
                    ),
                  ),
                  // ExperimentInfoCard(
                  //   title: FlutterI18n.translate(
                  //     context,
                  //     "experiment.score_sum",
                  //     translationParams: {"sum": controller.sum.toString()},
                  //   ),
                  // ),
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
              );
            } else if (controller.physicsStatus == ExperimentStatus.error &&
                controller.otherStatus == ExperimentStatus.error) {
              return ReloadWidget(
                function: controller.get,
                errorStatus: FlutterI18n.translate(
                  context,
                  "${controller.physicsStatusError} ${controller.otherStatusError}",
                ),
              ).center();
            } else {
              return CircularProgressIndicator().center();
            }
          },
        ),
      ),
    );
  }
}
