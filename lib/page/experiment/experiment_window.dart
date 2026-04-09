// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/model/password_exceptions.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/experiment/experiment_info_card.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/loading_alerter.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class ExperimentWindow extends StatefulWidget {
  const ExperimentWindow({super.key});

  @override
  State<ExperimentWindow> createState() => _ExperimentWindowState();
}

class _ExperimentWindowState extends State<ExperimentWindow> {
  String _resolveLoadingHintKey({
    required bool physicsLoading,
    required bool otherLoading,
    required bool physicsFatalError,
    required bool otherFatalError,
  }) {
    if (physicsLoading && otherLoading) {
      return "experiment.fetching_hint_both";
    }
    if (physicsLoading && otherFatalError) {
      return "experiment.fetching_hint_physics_with_other_failed";
    }
    if (otherLoading && physicsFatalError) {
      return "experiment.fetching_hint_other_with_physics_failed";
    }
    if (physicsLoading) {
      return "experiment.fetching_hint_physics";
    }
    return "experiment.fetching_hint_other";
  }

  String _resolveCacheHint(
    BuildContext context, {
    required String? hintKey,
    required DateTime fetchTime,
  }) {
    return FlutterI18n.translate(
      context,
      hintKey ?? "local_cache_hint",
      translationParams: {"datetime": fetchTime.toString()},
    );
  }

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

  Widget _buildPhysicsErrorCard(BuildContext context, Object physicsError) {
    if (physicsError is NoPasswordException &&
        physicsError.type == PasswordType.physicsExperiment) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 0,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                FlutterI18n.translate(
                  context,
                  "experiment_controller.no_password",
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () async {
                  final updated = await showDialog<bool>(
                    context: context,
                    builder: (context) => const ExperimentPasswordDialog(),
                  );
                  if (updated != true || !context.mounted) return;
                  await PhysicsExperimentController.i.reloadPhysicsExperiment();
                },
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.change_experiment_title",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ExperimentInfoCard(
      title: FlutterI18n.translate(
        context,
        "experiment.error_physics",
        translationParams: {"info": physicsError.toString()},
      ),
    );
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
            dataType: FlutterI18n.translate(
              context,
              "experiment.physics_experiment",
            ),
            hint: _resolveCacheHint(
              context,
              hintKey: PhysicsExperimentController
                  .i
                  .physicsExperimentCacheHintKey
                  .value,
              fetchTime: physicsFetchTime,
            ),
          ),
        if (isOtherFromCache && otherFetchTime != null)
          CacheAlerter(
            dataType: FlutterI18n.translate(
              context,
              "experiment.other_experiment",
            ),
            hint: _resolveCacheHint(
              context,
              hintKey:
                  OtherExperimentController.i.otherExperimentCacheHintKey.value,
              fetchTime: otherFetchTime,
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
                _buildPhysicsErrorCard(context, physicsError),
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

      final physicsLoading = physicsState.isLoading;
      final otherLoading = otherState.isLoading;
      final isLoading = physicsLoading || otherLoading;

      final physicsFatalError = physicsState is AsyncError && !hasValidPhysics;
      final physicsError = physicsFatalError ? physicsState.error : null;

      final otherFatalError = otherState is AsyncError && !hasValidOther;
      final otherError = otherFatalError ? otherState.error : null;

      final loadingHintKey = isLoading
          ? _resolveLoadingHintKey(
              physicsLoading: physicsLoading,
              otherLoading: otherLoading,
              physicsFatalError: physicsFatalError,
              otherFatalError: otherFatalError,
            )
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
              if (physicsFatalError && otherFatalError) {
                return ReloadWidget(
                  function: _reloadAll,
                  errorStatus:
                      "Physics: ${physicsError.toString()}\n"
                      "Others: ${otherError.toString()}",
                ).center();
              }

              return Stack(
                children: [
                  const Center(child: CircularProgressIndicator()),
                  if (loadingHintKey != null)
                    LoadingAlerter(
                      isLoading: true,
                      hint: FlutterI18n.translate(context, loadingHintKey),
                      opacity: 0,
                      showOverlay: false,
                    ),
                ],
              );
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
              physicsError: physicsFatalError ? physicsState.error : null,
              otherError: otherFatalError ? otherState.error : null,
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
                  hint: FlutterI18n.translate(context, loadingHintKey!),
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
