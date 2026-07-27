// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
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
import 'package:watermeter/generated/l10n.dart';

class ExperimentWindow extends StatefulWidget {
  const ExperimentWindow({super.key});

  @override
  State<ExperimentWindow> createState() => _ExperimentWindowState();
}

class _ExperimentWindowState extends State<ExperimentWindow> {
  String _resolveLoadingHint(
    BuildContext context, {
    required bool physicsLoading,
    required bool otherLoading,
    required bool physicsFatalError,
    required bool otherFatalError,
  }) {
    if (physicsLoading && otherLoading) {
      return I18n.of(context)!.experimentFetchingHintBoth;
    }
    if (physicsLoading && otherFatalError) {
      return I18n.of(context)!.experimentFetchingHintPhysicsWithOtherFailed;
    }
    if (otherLoading && physicsFatalError) {
      return I18n.of(context)!.experimentFetchingHintOtherWithPhysicsFailed;
    }
    if (physicsLoading) {
      return I18n.of(context)!.experimentFetchingHintPhysics;
    }
    return I18n.of(context)!.experimentFetchingHintOther;
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
                I18n.of(context)!.experimentControllerNoPassword,
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
                  I18n.of(context)!.settingChangeExperimentTitle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ExperimentInfoCard(
      title: I18n.of(context)!.experimentErrorPhysics(physicsError.toString()),
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
            dataType: I18n.of(context)!.experimentPhysicsExperiment,
            hint: PhysicsExperimentController.i.physicsExperimentCacheHintKey.value?.resolve(I18n.of(context)!) ?? I18n.of(context)!.cacheReasonDefault,
            placeOfCache: PlaceOfCache.device,
            fetchTime: physicsFetchTime,
          ),
        if (isOtherFromCache && otherFetchTime != null)
          CacheAlerter(
            dataType: I18n.of(context)!.experimentOtherExperiment,
            hint: OtherExperimentController.i.otherExperimentCacheHintKey.value?.resolve(I18n.of(context)!) ?? I18n.of(context)!.cacheReasonDefault,
            placeOfCache: PlaceOfCache.device,
            fetchTime: otherFetchTime,
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
                  title: I18n.of(context)!.experimentErrorOther(otherError.toString()),
                ),
              ExperimentInfoCard(
                title: I18n.of(context)!.experimentScoreHint0,
              ),
              if (doing.isNotEmpty) ...[
                TimelineTitle(
                  title: I18n.of(context)!.experimentOngoing,
                ),
                Column(
                  children: doing
                      .map((experiment) => ExperimentInfoCard(data: experiment))
                      .toList(),
                ),
              ],
              TimelineTitle(
                title: I18n.of(context)!.experimentNotFinished,
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
                      title: I18n.of(context)!.experimentAllFinished,
                    ),
              TimelineTitle(
                title: I18n.of(context)!.experimentFinished,
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
                      title: I18n.of(context)!.experimentNoneFinished,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final physicsController = PhysicsExperimentController.i;
        final otherController = OtherExperimentController.i;

        final physicsState =
            physicsController.physicsExperimentStateSignal.value;
        final otherState = otherController.otherExperimentStateSignal.value;

        final hasValidPhysics =
            physicsController.hasValidPhysicsExperiment.value;
        final hasValidOther = otherController.hasValidOtherExperiment.value;
        final hasAnyValidData = hasValidPhysics || hasValidOther;

        final physicsLoading = physicsState.isLoading;
        final otherLoading = otherState.isLoading;
        final isLoading = physicsLoading || otherLoading;

        final physicsFatalError =
            physicsState is AsyncError && !hasValidPhysics;
        final physicsError = physicsFatalError ? physicsState.error : null;

        final otherFatalError = otherState is AsyncError && !hasValidOther;
        final otherError = otherFatalError ? otherState.error : null;

        final loadingHint = isLoading
            ? _resolveLoadingHint(
                context,
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
          ...physicsController
              .isNotStartedPhysicsExperimentComputedSignal
              .value,
          ...otherController.isNotStartedOtherExperimentComputedSignal.value,
        ]);

        final done = _sortExperiments([
          ...physicsController.isFinishedPhysicsExperimentComputedSignal.value,
          ...otherController.isFinishedOtherExperimentComputedSignal.value,
        ]);

        return Scaffold(
          appBar: AppBar(
            title: Text(I18n.of(context)!.experimentTitle),
            actions: [
              if (!offline && hasAnyValidData)
                IconButton(
                  icon: const Icon(Icons.update),
                  onPressed: _reloadAll,
                ),
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
                    if (loadingHint != null)
                      LoadingAlerter(
                        isLoading: true,
                        hint: loadingHint,
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
                    hint: loadingHint!,
                    opacity: 0.15,
                    showOverlay: true,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
