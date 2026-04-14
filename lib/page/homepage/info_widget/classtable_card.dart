// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/homepage_controller.dart' as home;
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class _ClassTableCardItemDescriptor {
  List<HomeArrangement> displayArrangements = [];

  final String timeLabelPrefix;
  final IconData icon;
  final EdgeInsets padding;
  final bool isTomorrow;
  final bool isMultiArrangementsMode;
  final String emptyInfoText;

  _ClassTableCardItemDescriptor({
    required this.timeLabelPrefix,
    required this.icon,
    required this.padding,
    required this.emptyInfoText,
    this.isTomorrow = false,
    this.isMultiArrangementsMode = false,
  });

  bool get isNotEmpty => displayArrangements.isNotEmpty;

  void addArrangementIfNotNull(HomeArrangement? arr) {
    if (arr != null) {
      displayArrangements.add(arr);
    }
  }

  void addAllArrangements(Iterable<HomeArrangement> arrs) {
    displayArrangements.addAll(arrs);
  }
}

class ClassTableCard extends StatefulWidget {
  const ClassTableCard({super.key});

  static final RxBool simplifiedMode = preference
      .getBool(preference.Preference.simplifiedClassTimeline)
      .obs;

  static void reloadSettingsFromPref() {
    simplifiedMode.value = preference.getBool(
      preference.Preference.simplifiedClassTimeline,
    );
  }

  @override
  State<ClassTableCard> createState() => _ClassTableCardState();
}

class _ClassTableCardState extends State<ClassTableCard> {
  String _getFailedSourceLabel(home.HomepageFailedSource source) {
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

  Widget? _buildStateHints(
    BuildContext context, {
    required bool isAllSourcesLoading,
    required bool isPartialSourcesLoading,
    required List<home.HomepageFailedSource> failedSources,
  }) {
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
      hints.add(
        _buildStateHintChip(
          context,
          text: FlutterI18n.translate(
            context,
            "homepage.class_table_card.failed_chip",
            translationParams: {"source": _getFailedSourceLabel(source)},
          ),
          backgroundColor: theme.error,
          foregroundColor: theme.errorContainer,
        ),
      );
    }

    if (hints.isEmpty) {
      return null;
    }

    return Wrap(spacing: 8, runSpacing: 8, children: hints);
  }

  List<_ClassTableCardItemDescriptor> _getItemDescriptors({
    required HomeArrangement? currentArrangement,
    required HomeArrangement? nextArrangement,
    required List<HomeArrangement> arrangements,
    required int remainingCount,
    required bool isTomorrow,
    required String emptyInfoText,
    required bool simplifiedMode,
  }) {
    var currItem = _ClassTableCardItemDescriptor(
      timeLabelPrefix: FlutterI18n.translate(
        context,
        "homepage.class_table_card.current",
      ),
      icon: Icons.timelapse_outlined,
      padding: const EdgeInsets.fromLTRB(5, 0.5, 0, 10.0),
      emptyInfoText: emptyInfoText,
    );
    currItem.addArrangementIfNotNull(currentArrangement);

    var nextItem = _ClassTableCardItemDescriptor(
      timeLabelPrefix: isTomorrow
          ? FlutterI18n.translate(context, "homepage.class_table_card.tomorrow")
          : FlutterI18n.translate(context, "homepage.class_table_card.later"),
      icon: Icons.schedule_outlined,
      padding: const EdgeInsets.fromLTRB(5, 0.5, 0, 10.0),
      emptyInfoText: emptyInfoText,
      isTomorrow: isTomorrow,
    );
    nextItem.addArrangementIfNotNull(nextArrangement);

    var moreItem = _ClassTableCardItemDescriptor(
      timeLabelPrefix: FlutterI18n.translate(
        context,
        "homepage.class_table_card.more",
      ),
      icon: Icons.more_time_outlined,
      padding: const EdgeInsets.fromLTRB(5, 1.5, 0, 10.0),
      emptyInfoText: emptyInfoText,
      isMultiArrangementsMode: true,
    );
    final moreCount = remainingCount < 0
        ? 0
        : (remainingCount > arrangements.length
              ? arrangements.length
              : remainingCount);
    moreItem.addAllArrangements(
      arrangements.skip(arrangements.length - moreCount),
    );

    if (arrangements.isEmpty) {
      return [currItem];
    }

    if (!simplifiedMode) {
      return [currItem, nextItem, moreItem];
    }

    List<_ClassTableCardItemDescriptor> results = [];
    results.addIf(currItem.isNotEmpty, currItem);
    results.addIf(nextItem.isNotEmpty, nextItem);
    results.addIf(moreItem.isNotEmpty, moreItem);

    if (results.isEmpty) {
      results.add(currItem);
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
          final controller = home.HomepageController.i;
          final arrangementState =
              controller.homepageArrangementStateComputedSignal.value;
          final currentArrangement = controller.currentComputedSignal.value;
          final nextArrangement = controller.nextComputedSignal.value;
          final remainingCount = controller.remainingComputedSignal.value;
          final arrangements = controller.arrangementComputedSignal.value;
          final isTomorrow = controller.isTomorrowComputedSignal.value;
          final isAllSourcesLoading =
              controller.isAllSourcesLoadingComputedSignal.value;
          final isPartialSourcesLoading =
              controller.isPartialSourcesLoadingComputedSignal.value;
          final failedSources = controller.failedSourcesComputedSignal.value;
          final itemDesc = _getItemDescriptors(
            currentArrangement: currentArrangement,
            nextArrangement: nextArrangement,
            arrangements: arrangements,
            remainingCount: remainingCount,
            isTomorrow: isTomorrow,
            emptyInfoText: _getEmptyInfoText(arrangementState),
            simplifiedMode: ClassTableCard.simplifiedMode.value,
          );
          final hintWidget = _buildStateHints(
            context,
            isAllSourcesLoading: isAllSourcesLoading,
            isPartialSourcesLoading: isPartialSourcesLoading,
            failedSources: failedSources,
          );

          return [
            hintWidget,
            FixedTimeline.tileBuilder(
              theme: TimelineThemeData(
                nodePosition: 0,
                color: Theme.of(context).colorScheme.primary,
              ),
              builder: TimelineTileBuilder(
                itemCount: itemDesc.length,
                contentsAlign: ContentsAlign.basic,
                contentsBuilder: (context, index) => Padding(
                  padding: itemDesc[index].padding,
                  child: _ClassTableCardItem(itemDesc[index]),
                ),
                indicatorBuilder: (context, index) => Indicator.widget(
                  position: 0,
                  child: Icon(
                    itemDesc[index].icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                startConnectorBuilder: (context, index) {
                  if (index == 0) {
                    return null;
                  }
                  if (itemDesc[index].isTomorrow) {
                    return Connector.dashedLine(gap: 4, thickness: 3);
                  }
                  return Connector.solidLine(thickness: 3);
                },
                endConnectorBuilder: (context, index) {
                  if (index + 1 < itemDesc.length &&
                      itemDesc[index + 1].isTomorrow) {
                    return Connector.dashedLine(gap: 4, thickness: 3);
                  }
                  return Connector.solidLine(thickness: 3);
                },
              ),
            ),
          ].whereType<Widget>().toList().toColumn(
            separator: const SizedBox(height: 10),
          );
        })
        .paddingDirectional(horizontal: 20, vertical: 14)
        .withHomeCardStyle(
          context,
          onPressed: () {
            context.pushReplacement(
              LayoutBuilder(
                builder: (context, constraints) => ClassTableWindow(
                  parentContext: context,
                  currentWeek:
                      ClassTableController.i.currentWeekComputedSignal.value,
                  constraints: constraints,
                ),
              ),
            );
          },
        );
  }
}

class _ClassTableCardItem extends StatelessWidget {
  final _ClassTableCardItemDescriptor descriptor;

  const _ClassTableCardItem(this.descriptor);

  @override
  Widget build(BuildContext context) {
    List<Widget> columns = [
      Text(
        getTimeText(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ).alignment(Alignment.centerLeft),
    ];

    if (descriptor.isMultiArrangementsMode) {
      columns.addAll(getMultiArrangementsColumns(context));
    } else {
      columns.addAll(getSingleOrZeroArrangementColumns(context));
    }

    return columns.toColumn(separator: const SizedBox(height: 4.0));
  }

  String getTimeText() {
    String timeText = descriptor.timeLabelPrefix;
    DateFormat formatter = DateFormat("HH:mm");
    if (!descriptor.isMultiArrangementsMode && descriptor.isNotEmpty) {
      HomeArrangement arr = descriptor.displayArrangements[0];
      timeText +=
          " ${formatter.format(arr.startTime)} - ${formatter.format(arr.endTime)}";
    }
    return timeText;
  }

  Iterable<Widget> getSingleOrZeroArrangementColumns(BuildContext context) {
    HomeArrangement? arr = descriptor.displayArrangements.firstOrNull;

    late String infoText;
    if (arr != null) {
      infoText = arr.name;
    } else {
      infoText = descriptor.emptyInfoText;
    }

    List<Widget> columns = [
      Text(
        infoText,
        style: const TextStyle(
          height: 1.1,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ).alignment(Alignment.centerLeft).expanded(),
    ];

    if (arr != null) {
      var detail = _ClassTableCardArrangementDetail(displayArrangement: arr);
      columns.addIf(!detail.isContentEmpty, detail);
    }
    return columns;
  }

  Iterable<Widget> getMultiArrangementsColumns(BuildContext context) {
    return descriptor.displayArrangements.map(
      (arr) =>
          [
            Text(
              DateFormat("HH:mm").format(arr.startTime),
              style: const TextStyle(
                height: 1.2,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ).alignment(Alignment.topLeft),
            Text(
              arr.name,
              style: const TextStyle(
                height: 1.1,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ).alignment(Alignment.topLeft).expanded(),
          ].toRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            separator: const SizedBox(width: 8.0),
          ),
    );
  }
}

class _ClassTableCardArrangementDetail extends StatelessWidget {
  final HomeArrangement displayArrangement;

  const _ClassTableCardArrangementDetail({required this.displayArrangement});

  bool get isContentEmpty =>
      displayArrangement.place == null &&
      displayArrangement.seat == null &&
      displayArrangement.teacher == null;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    if (displayArrangement.place != null) {
      items.add(createIconText(context, Icons.room, displayArrangement.place!));
    }

    if (displayArrangement.seat != null) {
      items.add(
        createIconText(
          context,
          Icons.chair,
          displayArrangement.seat!.toString(),
        ),
      );
    }

    if (displayArrangement.teacher != null) {
      items.add(
        createIconText(context, Icons.person, displayArrangement.teacher!),
      );
    }

    return items.toRow(separator: const SizedBox(width: 6));
  }

  Widget createIconText(BuildContext context, IconData icon, String text) {
    return [
      Icon(
        icon,
        color: Theme.of(context).brightness == Brightness.dark
            ? null
            : Theme.of(context).colorScheme.onPrimaryFixedVariant,
        size: 18,
      ),
      Text(text, style: const TextStyle(fontSize: 14)),
    ].toRow(separator: const SizedBox(width: 2));
  }
}
