// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/page/experiment/experiment_info_card.dart';
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
      appBar: AppBar(title: const Text("物理实验")),
      body: GetBuilder<ExperimentController>(
        builder: (controller) {
          if (controller.status == ExperimentStatus.fetched ||
              controller.status == ExperimentStatus.cache) {
            var doing = controller.doing(now);
            var unDone = controller.isNotFinished(now);
            var done = controller.isFinished(now);
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
                  title: "目前分数总和：${controller.sum}",
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
                        title: "目前没有已经完成的实验",
                      ),
              ],
            );
          } else if (controller.status == ExperimentStatus.error) {
            return Center(child: Text(controller.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
