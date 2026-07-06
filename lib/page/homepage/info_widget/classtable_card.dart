// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/homepage_controller.dart' as home;
import 'package:watermeter/controller/homepage_controller.dart';
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';

class ClassTableCard extends StatefulWidget {
  const ClassTableCard({super.key});

  static final ValueNotifier<bool> simplifiedMode = ValueNotifier<bool>(
    preference.getBool(preference.Preference.simplifiedClassTimeline),
  );

  static void reloadSettingsFromPref() {
    simplifiedMode.value = preference.getBool(
      preference.Preference.simplifiedClassTimeline,
    );
  }

  @override
  State<ClassTableCard> createState() => _ClassTableCardState();
}

class _ClassTableCardState extends State<ClassTableCard> {
  String _getEmptyInfoText(home.ArrangementState state) {
    switch (state) {
      case home.ArrangementState.fetching:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.schedule_fetching_infoText",
        );
      case home.ArrangementState.error:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.schedule_error_infoText",
        );
      case home.ArrangementState.none:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.schedule_none_infoText",
        );
      case home.ArrangementState.fetched:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.no_arrangement_infoText",
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
          builder: (context) {
            final controller = home.HomepageController.i;
            final classTableController = ClassTableController.i;
            final arrangementState =
                controller.homepageArrangementStateComputedSignal.value;
            final arrangements = controller.arrangementComputedSignal.value;
            final isTomorrow = controller.isTomorrowComputedSignal.value;
            final updateTime = controller.updateTimeComputedSignal.value;
            final displayTime = isTomorrow
                ? updateTime.add(const Duration(days: 1))
                : updateTime;
            final isAllSourcesLoading =
                controller.isAllSourcesLoadingComputedSignal.value;
            final isPartialSourcesLoading =
                controller.isPartialSourcesLoadingComputedSignal.value;
            final failedSources = controller.failedSourcesComputedSignal.value;
            final havePhysicsExperiment =
                controller.havePhysicsExperimentSignal.value;
            final isPostGraduate = controller.isPostGraduate;
            final currentWeek = classTableController.getCurrentWeek(
              displayTime,
            );
            final semesterLength = classTableController
                .classTableComputedSignal
                .value
                .semesterLength;

            return [
              _StateList(
                isAllSourcesLoading: isAllSourcesLoading,
                isPartialSourcesLoading: isPartialSourcesLoading,
                failedSources: failedSources,
                havePhysicsExperiment: havePhysicsExperiment,
                isPostGraduate: isPostGraduate,
              ),
              _ClassArrangementListView(
                arrangements: arrangements,
                isTomorrow: isTomorrow,
                emptyInfoText: _getEmptyInfoText(arrangementState),
                arrangementState: arrangementState,
                displayTime: displayTime,
                currentWeek: currentWeek,
                semesterLength: semesterLength,
              ),
            ].whereType<Widget>().toList().toColumn(
              separator: const SizedBox(height: 10),
            );
          },
        )
        .paddingDirectional(horizontal: 16, vertical: 8)
        .withHomeCardStyle(
          context,
          onPressed: () {
            context.pushReplacementNamed(Routes.classTable);
          },
        );
  }
}

class _ClassArrangementListView extends StatelessWidget {
  final List<HomeArrangement> arrangements;
  final bool isTomorrow;
  final String emptyInfoText;
  final ArrangementState arrangementState;
  final DateTime displayTime;
  final int currentWeek;
  final int semesterLength;

  const _ClassArrangementListView({
    required this.arrangements,
    required this.isTomorrow,
    required this.emptyInfoText,
    required this.arrangementState,
    required this.displayTime,
    required this.currentWeek,
    required this.semesterLength,
  });

  @override
  Widget build(BuildContext context) {
    return [
      [
        Icon(Icons.calendar_month, size: 32),
        SizedBox(width: 18),
        [
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: Builder(
              builder: (context) {
                if (isTomorrow) {
                  if (arrangements.isEmpty) {
                    return Text(
                      FlutterI18n.translate(
                        context,
                        "homepage.class_table_card.tomorrow_none",
                      ),
                    );
                  }
                  return Text(
                    FlutterI18n.translate(
                      context,
                      "homepage.class_table_card.tomorrow",
                      translationParams: {
                        "remain": arrangements.length.toString(),
                      },
                    ),
                  );
                }
                if (arrangements.isEmpty) {
                  return Text(
                    FlutterI18n.translate(
                      context,
                      "homepage.class_table_card.today_finished",
                    ),
                  );
                }
                return Text(
                  FlutterI18n.translate(
                    context,
                    "homepage.class_table_card.today",
                    translationParams: {
                      "remain": arrangements.length.toString(),
                    },
                  ),
                );
              },
            ),
          ),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: Builder(
              builder: (context) {
                String timeString = DateFormat(
                  "MMMd",
                  FlutterI18n.currentLocale(context).toString(),
                ).format(displayTime);

                String weekString = DateFormat(
                  "E",
                  FlutterI18n.currentLocale(context).toString(),
                ).format(displayTime);

                String weekInfo =
                    currentWeek >= 0 && currentWeek < semesterLength
                    ? FlutterI18n.translate(
                        context,
                        "homepage.class_table_card.week_info",
                        translationParams: {"weekinfo": "${currentWeek + 1}"},
                      )
                    : FlutterI18n.translate(
                        context,
                        "homepage.class_table_card.on_holiday",
                      );

                String toShow = switch (arrangementState) {
                  home.ArrangementState.fetched =>
                    "$timeString $weekString $weekInfo",
                  home.ArrangementState.error => FlutterI18n.translate(
                    context,
                    "homepage.load_error",
                  ),
                  _ => FlutterI18n.translate(context, "homepage.loading"),
                };
                return Text(toShow);
              },
            ),
          ),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
      ].toRow(),
      SizedBox(height: 8),
      if (arrangements.isEmpty)
        Text(
              emptyInfoText,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
              ),
            )
            .center()
            .padding(horizontal: 10, vertical: 8)
            .decorated(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.125),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            )
            .width(double.infinity)
            .padding(vertical: 4)
      else
        [
          ...arrangements.asMap().entries.map(
            (entry) => _ClassArrangementListTile(
              arrangement: entry.value,
              colorIndex: entry.key,
            ),
          ),
        ].toColumn(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
  }
}

class _ClassArrangementListTile extends StatelessWidget {
  final HomeArrangement arrangement;
  final int colorIndex;
  const _ClassArrangementListTile({
    required this.arrangement,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final index = arrangement.colorIndex ?? colorIndex;
    final color = colorList[index % colorList.length];
    return [
          Container(
            width: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          SizedBox(width: 8),
          [
                Text(
                  arrangement.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Builder(
                  builder: (context) {
                    String place =
                        arrangement.place ??
                        FlutterI18n.translate(
                          context,
                          "homepage.class_table_card.unknown_place",
                        );
                    if (arrangement.seat != null) {
                      place += " ";
                      place += FlutterI18n.translate(
                        context,
                        "homepage.class_table_card.seat",
                        translationParams: {"seatnum": arrangement.seat!},
                      );
                    }
                    return Text(
                      place,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    );
                  },
                ),
              ]
              .toColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              )
              .expanded(),
          [
            Text(
              "${arrangement.startTime.hour.toString().padLeft(2, '0')}:"
              "${arrangement.startTime.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              "${arrangement.endTime.hour.toString().padLeft(2, '0')}:"
              "${arrangement.endTime.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ].toColumn(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ]
        .toRow(crossAxisAlignment: CrossAxisAlignment.stretch)
        .parent(({required child}) => IntrinsicHeight(child: child))
        .padding(horizontal: 8, vertical: 6)
        .decorated(
          color: color.withValues(alpha: 0.125),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        )
        .padding(vertical: 4);
  }
}

class _StateList extends StatelessWidget {
  final bool isAllSourcesLoading;
  final bool isPartialSourcesLoading;
  final List<home.HomepageFailedSource> failedSources;
  final bool havePhysicsExperiment;
  final bool isPostGraduate;

  const _StateList({
    required this.isAllSourcesLoading,
    required this.isPartialSourcesLoading,
    required this.failedSources,
    required this.havePhysicsExperiment,
    required this.isPostGraduate,
  });

  String _getFailedSourceLabel(
    BuildContext context,
    home.HomepageFailedSource source,
  ) {
    switch (source) {
      case home.HomepageFailedSource.classInfo:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.failed_source_class_info",
        );
      case home.HomepageFailedSource.examInfo:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.failed_source_exam_info",
        );
      case home.HomepageFailedSource.physicsExperiment:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.failed_source_physics_experiment",
        );
      case home.HomepageFailedSource.otherExperiment:
        return FlutterI18n.translate(
          context,
          "homepage.class_table_card.failed_source_other_experiment",
        );
    }
  }

  Widget _buildStateHintChip(
    BuildContext context, {
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
  }) => Chip(
    label: Text(text),
    labelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: foregroundColor,
    ),
    backgroundColor: backgroundColor,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final hints = <Widget>[];

    if (isAllSourcesLoading) {
      hints.add(
        _buildStateHintChip(
          context,
          text: FlutterI18n.translate(
            context,
            "homepage.class_table_card.all_loading_infoText",
          ),
          backgroundColor: theme.primary,
          foregroundColor: theme.primaryContainer,
        ),
      );
    } else if (isPartialSourcesLoading) {
      hints.add(
        _buildStateHintChip(
          context,
          text: FlutterI18n.translate(
            context,
            "homepage.class_table_card.partial_loading_infoText",
          ),
          backgroundColor: theme.primary,
          foregroundColor: theme.primaryContainer,
        ),
      );
    }

    for (final source in failedSources) {
      // If there's no physics experiment needed, skip any error related to it
      if (source == home.HomepageFailedSource.physicsExperiment &&
          !havePhysicsExperiment) {
        continue;
      }

      // If post graduate, no other experiment needed, skip any error related to it
      if (source == home.HomepageFailedSource.otherExperiment &&
          isPostGraduate) {
        continue;
      }
      hints.add(
        _buildStateHintChip(
          context,
          text: FlutterI18n.translate(
            context,
            "homepage.class_table_card.failed_chip",
            translationParams: {
              "source": _getFailedSourceLabel(context, source),
            },
          ),
          backgroundColor: theme.error,
          foregroundColor: theme.errorContainer,
        ),
      );
    }

    if (hints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 8, runSpacing: 8, children: hints);
  }
}
