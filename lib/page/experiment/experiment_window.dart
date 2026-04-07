// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/experiment/experiment_info_card.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/loading_alerter.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class ExperimentWindow extends StatefulWidget {
  const ExperimentWindow({super.key});

  @override
  State<ExperimentWindow> createState() => _ExperimentWindowState();
}

class _ExperimentWindowState extends State<ExperimentWindow> {
  List<ExperimentData> _sortExperiments(Iterable<ExperimentData> data) {
    final result = data.toList();
    DateTime firstStartTime(ExperimentData data) {
      final timeRanges = data.timeRanges.map((e) => e.$1).toList()..sort();
      return timeRanges.first;
    }

    result.sort((a, b) => firstStartTime(a).compareTo(firstStartTime(b)));
    return result;
  }

  Future<void> _reloadAll() async {
    await Future.wait([
      PhysicsExperimentController.i.reloadPhysicsExperiment(),
      OtherExperimentController.i.reloadOtherExperiment(),
    ]);
  }

  Widget _buildExperimentList(
    BuildContext context, {
    required List<ExperimentData> doing,
    required List<ExperimentData> unDone,
    required List<ExperimentData> done,
    required bool isPhysicsFromCache,
    required bool isOtherFromCache,
    required DateTime? physicsFetchTime,
    required DateTime? otherFetchTime,
    required Object? physicsError,
    required Object? otherError,
  }) {
    return Column(
      children: [
        if (isPhysicsFromCache && physicsFetchTime != null)
          CacheAlerter(
            hint: FlutterI18n.translate(
              context,
              "inapp_cache_hint",
              translationParams: {"datetime": physicsFetchTime.toString()},
            ),
          ),
        if (isOtherFromCache && otherFetchTime != null)
          CacheAlerter(
            hint: FlutterI18n.translate(
              context,
              "inapp_cache_hint",
              translationParams: {"datetime": otherFetchTime.toString()},
            ),
          ),
        Expanded(
          child: TimelineWidget(
            isTitle: [
              if (physicsError != null) false,
              if (otherError != null) false,
              false,
              if (doing.isNotEmpty) ...[true, false],
              true,
              false,
              true,
              false,
            ],
            children: [
              if (physicsError != null)
                ExperimentInfoCard(
                  title: FlutterI18n.translate(
                    context,
                    "experiment.error_physics",
                    translationParams: {"info": physicsError.toString()},
                  ),
                ),
              if (otherError != null)
                ExperimentInfoCard(
                  title: FlutterI18n.translate(
                    context,
                    "experiment.error_other",
                    translationParams: {"info": otherError.toString()},
                  ),
                ),
              ExperimentInfoCard(
                title: FlutterI18n.translate(
                  context,
                  "experiment.score_hint_0",
                ),
              ),
              if (doing.isNotEmpty) ...[
                TimelineTitle(
                  title: FlutterI18n.translate(context, "experiment.ongoing"),
                ),
                Column(
                  children: doing
                      .map((experiment) => ExperimentInfoCard(data: experiment))
                      .toList(),
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
                      children: unDone
                          .map(
                            (experiment) =>
                                ExperimentInfoCard(data: experiment),
                          )
                          .toList(),
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
              done.isNotEmpty
                  ? Column(
                      children: done
                          .map(
                            (experiment) =>
                                ExperimentInfoCard(data: experiment),
                          )
                          .toList(),
                    )
                  : TimelineTitle(
                      title: FlutterI18n.translate(
                        context,
                        "experiment.none_finished",
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final physicsController = PhysicsExperimentController.i;
      final otherController = OtherExperimentController.i;

      final physicsState = physicsController.physicsExperimentSignal.value;
      final otherState = otherController.otherExperimentSignal.value;

      final hasValidPhysics = physicsController.hasValidPhysicsExperiment.value;
      final hasValidOther = otherController.hasValidOtherExperiment.value;
      final hasAnyValidData = hasValidPhysics || hasValidOther;

      final isLoading = physicsState.isLoading || otherState.isLoading;
      final physicsError = physicsState is AsyncError && !hasValidPhysics
          ? physicsState.error
          : null;
      final otherError = otherState is AsyncError && !hasValidOther
          ? otherState.error
          : null;

      final doing = _sortExperiments([
        ...physicsController.isDoingPhysicsExperimentComputedSignal.value,
        ...otherController.isDoingOtherExperimentComputedSignal.value,
      ]);
      final unDone = _sortExperiments([
        ...physicsController.isNotStartedPhysicsExperimentComputedSignal.value,
        ...otherController.isNotStartedOtherExperimentComputedSignal.value,
      ]);
      final done = _sortExperiments([
        ...physicsController.isFinishedPhysicsExperimentComputedSignal.value,
        ...otherController.isFinishedOtherExperimentComputedSignal.value,
      ]);

      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "experiment.title")),
          actions: [
            if (!offline && hasAnyValidData)
              IconButton(icon: const Icon(Icons.update), onPressed: _reloadAll),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (!hasAnyValidData) {
              if (physicsError != null && otherError != null) {
                return ReloadWidget(
                  function: _reloadAll,
                  errorStatus:
                      "Physics: ${physicsError.toString()}\n"
                      "Others: ${otherError.toString()}",
                ).center();
              }

              return const Center(child: CircularProgressIndicator());
            }

            final content = _buildExperimentList(
              context,
              doing: doing,
              unDone: unDone,
              done: done,
              isPhysicsFromCache:
                  physicsController.isPhysicsExperimentFromCache.value,
              isOtherFromCache:
                  otherController.isOtherExperimentFromCache.value,
              physicsFetchTime:
                  physicsController.physicsExperimentFetchTime.value,
              otherFetchTime: otherController.otherExperimentFetchTime.value,
              physicsError: physicsState is AsyncError
                  ? physicsState.error
                  : null,
              otherError: otherState is AsyncError ? otherState.error : null,
            );

            if (!isLoading) return content;

            return Stack(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      height: kTextTabBarHeight,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    Expanded(child: content),
                  ],
                ),
                LoadingAlerter(
                  isLoading: true,
                  hint: FlutterI18n.translate(
                    context,
                    "experiment.fetching_hint",
                  ),
                  opacity: 0.15,
                  showOverlay: true,
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
