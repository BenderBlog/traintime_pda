// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_page/class_change_list.dart';
import 'package:watermeter/page/classtable/class_page/classtable_inline_banner.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_sheet.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/class_page/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/class_page/week_choice_view.dart';
import 'package:watermeter/page/classtable/class_page/week_selection_highlight.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ContentClassTablePage extends StatefulWidget {
  const ContentClassTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _ContentClassTablePageState();
}

class _ContentClassTablePageState extends State<ContentClassTablePage> {
  /// Check whether listener is pushed...
  //bool isPushedListener = false;

  /// A lock of the week choice row.
  /// When locked, choiceWeek cannot be changed.
  bool isTopRowLocked = false;

  /// Classtable pageView controller.
  late PageController pageControl;

  /// Week choice row controller.
  ///
  /// A plain scroll controller rather than a page controller: the week row scrolls continuously so
  /// it can be dragged freely, instead of snapping from one week button to the next.
  late ScrollController rowControl;

  /// Set while [ClassTableWidgetState.chosenWeek] changes because the table itself was dragged.
  ///
  /// Such a change waits until the page settles, so the week row does not rebuild during the drag.
  bool _chosenWeekFromTable = false;

  /// Set while the week row's highlight is waiting for the pages to come to rest before it redraws.
  ///
  /// A week change redraws the week row and every week page with it, which is easily a frame's worth
  /// of work. Doing that in the middle of a drag is what made the table itself stutter, so it waits
  /// until the pages are still, where the very same work costs nothing anyone can see.
  bool _weekRowRefreshPending = false;

  /// Whether a frame callback is already watching for the pages to stop.
  bool _settleWatchScheduled = false;

  /// The page offset the watch last saw, which is how it tells "still moving" from "stopped".
  double _lastPagePixels = 0;

  /// The wallpaper behind the table. It stays sharp: the frosted look belongs to the backgrounds of
  /// the controls on top of it, not to the wallpaper itself.
  late BoxDecoration decoration;

  late ClassTableWidgetState classTableState;
  bool _isListening = false;
  bool _didLoadVisualSettings = false;
  /// Whether the week bar is tucked into the app bar.
  ///
  /// Pinned is the default, so the stored flag is the opposite of it and an unset preference reads
  /// back as `false`.
  bool _weekBarCollapsed = preference.getBool(
    preference.Preference.classTableWeekBarCollapsed,
  );

  /// Whether the collapsed bar is currently opened over the table. Only meaningful while collapsed.
  bool _weekBarExpanded = false;

  /// The height the week bar takes, either in the page or floating.
  double get _weekBarHeight => MediaQuery.sizeOf(context).height >= 500
      ? topRowHeightBig
      : topRowHeightSmall;

  /// Rebuilds and repositions the week row once the pages have stopped moving.
  void _watchPageSettle(double pixels) {
    _lastPagePixels = pixels;
    if (_settleWatchScheduled) {
      return;
    }
    _settleWatchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback(_onSettleWatchFrame);
  }

  void _onSettleWatchFrame(Duration _) {
    _settleWatchScheduled = false;
    if (!mounted || !_weekRowRefreshPending) {
      return;
    }
    if (pageControl.hasClients) {
      final double pixels = pageControl.position.pixels;
      if ((pixels - _lastPagePixels).abs() > 0.01) {
        /// Still moving: look again on the next frame.
        _watchPageSettle(pixels);
        return;
      }
    }
    _weekRowRefreshPending = false;
    final double? offset = _weekRowOffset(
      classTableState.chosenWeek.toDouble(),
    );
    if (offset != null) {
      rowControl.jumpTo(offset);
    }
    setState(() {});
  }

  /// The week row offset that shows the week [weeks] weeks into the semester.
  ///
  /// Null while the row cannot be measured yet.
  double? _weekRowOffset(double weeks) {
    if (!rowControl.hasClients) {
      return null;
    }
    final ScrollPosition rowPosition = rowControl.position;
    if (!rowPosition.hasContentDimensions) {
      return null;
    }
    return (weeks * weekChoiceItemExtent)
        .clamp(rowPosition.minScrollExtent, rowPosition.maxScrollExtent)
        .toDouble();
  }

  /// Keeps the week row on the same week as the table while the table moves.
  ///
  /// One table page is one week and one row item is one week, so the row's offset is the page's
  /// progress in weeks times [weekChoiceItemExtent]. Following the page frame by frame is what gives
  /// the row its easing: it rides the page's own animation curve when the week is picked elsewhere,
  /// and it stays under the finger when the table itself is dragged.
  void _syncWeekRowToTable() {
    /// While the page is running a week change picked elsewhere, the row is left where it is so the
    /// highlight can visibly slide from the old week to the new one. Only the table's own drag moves
    /// the row along.
    if (isTopRowLocked) {
      return;
    }
    if (!pageControl.hasClients) {
      return;
    }
    final ScrollPosition pagePosition = pageControl.position;
    if (!pagePosition.hasViewportDimension ||
        pagePosition.viewportDimension <= 0) {
      return;
    }
    final double? offset = _weekRowOffset(
      pagePosition.pixels / pagePosition.viewportDimension,
    );
    if (offset != null) {
      rowControl.jumpTo(offset);
    }
  }

  void _switchPage() {
    if (!mounted) {
      return;
    }

    /// A week picked by dragging the table is already moving on screen. Defer the week row update
    /// until the page settles so the drag does not rebuild the overview buttons on every page tick.
    if (_chosenWeekFromTable) {
      _weekRowRefreshPending = true;
      if (!_settleWatchScheduled &&
          pageControl.hasClients &&
          pageControl.position.hasPixels) {
        _watchPageSettle(pageControl.position.pixels);
      }
      return;
    }

    setState(() => isTopRowLocked = true);

    /// The highlight slides to the chosen week on its own, so the row is only nudged when that week
    /// would otherwise be off screen. Watching the page scroll is paused for the duration (see
    /// [_syncWeekRowToTable]), which is what lets the highlight be seen moving.
    _revealWeekRow(classTableState.chosenWeek);

    /// The page is animated independently; the row ends up on the same week either way.
    pageControl
        .animateToPage(
          classTableState.chosenWeek,
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: changePageTime),
        )
        .then((value) {
          if (!mounted) {
            return;
          }

          /// The row can be scrolled on its own, so make sure the chosen week is at least in view
          /// once the page has landed. When it already is, this does nothing.
          _revealWeekRow(classTableState.chosenWeek);
          isTopRowLocked = false;
        });
  }

  /// Brings [week]'s button into view, if it is not there already.
  ///
  /// Deliberately not an alignment: when the week is already on screen the row is left exactly where
  /// it is, so picking a neighbouring week slides the highlight across rather than dragging the whole
  /// row along with it. The row only moves when the new week would otherwise be off screen.
  void _revealWeekRow(int week) {
    if (!rowControl.hasClients) {
      return;
    }
    final ScrollPosition rowPosition = rowControl.position;
    if (!rowPosition.hasContentDimensions) {
      return;
    }
    final double left = week * weekChoiceItemExtent;
    final double right = left + weekChoiceItemExtent;
    final double offset = rowControl.offset;
    double? target;
    if (left < offset) {
      target = left;
    } else if (right > offset + rowPosition.viewportDimension) {
      target = right - rowPosition.viewportDimension;
    }
    if (target == null) {
      return;
    }
    rowControl.animateTo(
      target
          .clamp(rowPosition.minScrollExtent, rowPosition.maxScrollExtent)
          .toDouble(),
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: changePageTime),
    );
  }

  @override
  void dispose() {
    classTableState.removeListener(_switchPage);
    pageControl.removeListener(_syncWeekRowToTable);
    pageControl.dispose();
    rowControl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_didLoadVisualSettings) {
      CurrentTimeIndicatorConfig.loadFromPreference();
      CompletedClassStyleConfig.loadFromPreference();
      _didLoadVisualSettings = true;
    }

    if (!_isListening) {
      classTableState = ClassTableState.of(context)!.controllers;
      classTableState.addListener(_switchPage);

      /// Created once: rebuilding them on every dependency change would reset the row's scroll
      /// position and leak the previous controllers.
      pageControl = PageController(
        initialPage: classTableState.chosenWeek,
        keepPage: true,
      );
      rowControl = ScrollController(
        initialScrollOffset: classTableState.chosenWeek * weekChoiceItemExtent,
      );

      /// The table drives the week row while it moves, which is what gives the row its easing: it
      /// rides the page's own animation curve instead of jumping once the page has arrived.
      pageControl.addListener(_syncWeekRowToTable);

      _isListening = true;
    }

    /// Let controllers listen to the currentWeek's change.
    /// Init the background.
    File image = File("${supportPath.path}/${classTableState.decorationName}");
    decoration = BoxDecoration(
      image:
          (preference.getBool(preference.Preference.decorated) &&
              image.existsSync())
          ? DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
              opacity: Theme.of(context).brightness == Brightness.dark
                  ? 0.4
                  : 1.0,
            )
          : null,
    );
    super.didChangeDependencies();
  }

  /// A row shows a series of buttons about the classtable's index.
  ///
  /// This is at the top of the classtable. It contains a series of
  /// buttons which shows the week index, as well as an overview in a 5x5 dot gridview.
  ///
  /// When user click on the button, the pageview will show the class table of the
  /// week the button suggested.
  Widget _weekRow() {
    return Stack(
      children: [
        /// The highlight sits behind the buttons, sliding from week to week.
        Positioned.fill(
          child: IgnorePointer(
            child: WeekSelectionHighlight(
              week: classTableState.chosenWeek,
              rowControl: rowControl,
            ),
          ),
        ),
        ListView.builder(
          controller: rowControl,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemExtent: weekChoiceItemExtent,
          itemCount: classTableState.semesterLength,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: weekButtonHorizontalPadding,
              ),
              child: Card(
                /// Transparent: the highlight is the box behind the row, not a tint per button.
                color: Colors.transparent,
                elevation: 0.0,
                child: InkWell(
                  /// The following themes are the same as the Material 3 Card Radius.
                  borderRadius: const BorderRadius.all(
                    Radius.circular(weekChoiceCardRadius),
                  ),
                  onTap: () {
                    if (isTopRowLocked == false) {
                      classTableState.chosenWeek = index;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: WeekChoiceView(index: index),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Whether the bar is showing at all.
  ///
  /// Pinned means always; collapsed means only while the user has it open.
  bool get _weekBarVisible => !_weekBarCollapsed || _weekBarExpanded;

  /// Whether the bar floats over the table rather than sitting in the page.
  ///
  /// This is what the two modes animate between: floating is inset, rounded and shadowed, docked is
  /// flush with the app bar and takes its own strip.
  bool get _weekBarFloating => _weekBarCollapsed;

  /// The scrolling week buttons with the pin toggle at the end.
  ///
  /// One widget for both modes, so the two can animate into each other instead of being swapped.
  Widget _weekBarContents() {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Row(children: [Expanded(child: _weekRow()), _pinToggle()]),
    );
  }

  /// Pins the bar, or tucks it back into the app bar.
  Widget _pinToggle() {
    return IconButton(
      onPressed: _toggleWeekBarPinned,
      icon: Icon(
        _weekBarCollapsed ? Icons.push_pin_outlined : Icons.push_pin,
        size: 18,
      ),
      tooltip: FlutterI18n.translate(
        context,
        _weekBarCollapsed
            ? "classtable.week_bar.pin"
            : "classtable.week_bar.unpin",
      ),
    );
  }

  /// The mode is a preference, so it is remembered.
  Future<void> _toggleWeekBarPinned() async {
    final bool collapsed = !_weekBarCollapsed;
    await preference.setBool(
      preference.Preference.classTableWeekBarCollapsed,
      collapsed,
    );
    if (!mounted) return;
    setState(() {
      _weekBarCollapsed = collapsed;
      _weekBarExpanded = false;
    });
  }

  /// What the collapsed bar reduces to in the app bar: the week number, as a rounded chip.
  Widget _weekChip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHigh.withValues(
          alpha: timeLineSurfaceAlpha,
        ),
        borderRadius: BorderRadius.circular(timeLineRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(timeLineRadius),
          onTap: () => setState(() => _weekBarExpanded = !_weekBarExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              FlutterI18n.translate(
                context,
                "classtable.week_title",
                translationParams: {
                  "week": (classTableState.chosenWeek + 1).toString(),
                },
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLoadErrorDialog() async {
    final state = ClassTableState.of(context)!.controllers;
    final errorWithoutCacheSources = state.errorWithoutCacheSources;
    final errorWithCacheSources = state.errorWithCacheSources;

    String sourceLabel(ClassTableStatusSource source) =>
        FlutterI18n.translate(context, switch (source) {
          ClassTableStatusSource.classTable =>
            "classtable.status_source.class_table",
          ClassTableStatusSource.exam => "classtable.status_source.exam",
          ClassTableStatusSource.physicsExperiment =>
            "classtable.status_source.physics_experiment",
          ClassTableStatusSource.otherExperiment =>
            "classtable.status_source.other_experiment",
        });

    String? sourceHintKey(ClassTableStatusSource source) => switch (source) {
      ClassTableStatusSource.classTable => state.classTableCacheHintKey,
      ClassTableStatusSource.exam => state.examCacheHintKey,
      ClassTableStatusSource.physicsExperiment =>
        state.physicsExperimentCacheHintKey,
      ClassTableStatusSource.otherExperiment =>
        state.otherExperimentCacheHintKey,
    };

    final content = <String>[
      if (errorWithoutCacheSources.isNotEmpty)
        FlutterI18n.translate(
          context,
          "classtable.status_banner.error_summary",
          translationParams: {
            "sources": errorWithoutCacheSources.map(sourceLabel).join("、"),
          },
        ),
      ...errorWithoutCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? FlutterI18n.translate(context, hintKey)
            : FlutterI18n.translate(context, "network_error");
        return "${sourceLabel(source)}: $detail";
      }),
      if (errorWithoutCacheSources.isNotEmpty &&
          errorWithCacheSources.isNotEmpty)
        "",
      if (errorWithCacheSources.isNotEmpty)
        FlutterI18n.translate(
          context,
          "classtable.status_banner.cache",
          translationParams: {
            "sources": errorWithCacheSources.map(sourceLabel).join("、"),
          },
        ),
      ...errorWithCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? FlutterI18n.translate(context, hintKey)
            : FlutterI18n.translate(context, "network_error");
        return "${sourceLabel(source)}: $detail";
      }),
    ].join("\n");

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, "classtable.error_dialog_title"),
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  String _formatPercent(double value) => "${(value * 100).round()}%";

  // ignore: unused_element
  Future<void> _showCurrentTimeSettingsDialog() async {
    var enabled = CurrentTimeIndicatorConfig.enabled;
    var showTimeLabel = CurrentTimeIndicatorConfig.showTimeLabel;
    var showTodayColumnHighlight =
        CurrentTimeIndicatorConfig.showTodayColumnHighlight;

    final shouldApply =
        await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.current_time_settings_title",
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.show_current_time_indicator",
                          ),
                        ),
                        value: enabled,
                        onChanged: (value) =>
                            setDialogState(() => enabled = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.show_current_time_label",
                          ),
                        ),
                        value: showTimeLabel,
                        onChanged: enabled
                            ? (value) =>
                                  setDialogState(() => showTimeLabel = value)
                            : null,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.show_today_column_highlight",
                          ),
                        ),
                        value: showTodayColumnHighlight,
                        onChanged: (value) => setDialogState(
                          () => showTodayColumnHighlight = value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(FlutterI18n.translate(context, "cancel")),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(FlutterI18n.translate(context, "confirm")),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (!shouldApply || !mounted) {
      return;
    }

    CurrentTimeIndicatorConfig.enabled = enabled;
    CurrentTimeIndicatorConfig.showTimeLabel = showTimeLabel;
    CurrentTimeIndicatorConfig.showTodayColumnHighlight =
        showTodayColumnHighlight;
    await CurrentTimeIndicatorConfig.saveToPreference();
    setState(() {});
  }

  // ignore: unused_element
  Future<void> _showClassColorSettingsDialog() async {
    var completedEnabled = CompletedClassStyleConfig.completedEnabled;
    var activeBrightnessFactor = CompletedClassStyleConfig
        .activeBrightnessFactor
        .clamp(0.5, 1.0)
        .toDouble();
    var activeBorderAlpha = CompletedClassStyleConfig.activeBorderAlpha;
    var activeInnerAlpha = CompletedClassStyleConfig.activeInnerAlpha;
    var completedSaturationFactor =
        CompletedClassStyleConfig.completedSaturationFactor;
    var completedBrightnessFactor = CompletedClassStyleConfig
        .completedBrightnessFactor
        .clamp(0.5, 1.0)
        .toDouble();
    var completedTextSaturationFactor =
        CompletedClassStyleConfig.completedTextSaturationFactor;
    var completedBorderAlpha = CompletedClassStyleConfig.completedBorderAlpha;
    var completedInnerAlpha = CompletedClassStyleConfig.completedInnerAlpha;

    final shouldApply =
        await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.class_color_settings_title",
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.completed_style_enabled",
                          ),
                        ),
                        value: completedEnabled,
                        onChanged: (value) =>
                            setDialogState(() => completedEnabled = value),
                      ),
                      const Divider(height: 24),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "setting.class_table_style_page.unfinished_section",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                            "setting.class_table_style_page.active_brightness_factor",
                          translationParams: {
                            "value": _formatPercent(activeBrightnessFactor),
                          },
                        ),
                      ),
                      Slider(
                        value: activeBrightnessFactor,
                        min: 0.5,
                        max: 1.0,
                        divisions: 10,
                        onChanged: (value) => setDialogState(
                          () => activeBrightnessFactor = value,
                        ),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                            "setting.class_table_style_page.active_border_alpha",
                          translationParams: {
                            "value": _formatPercent(activeBorderAlpha),
                          },
                        ),
                      ),
                      Slider(
                        value: activeBorderAlpha,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        onChanged: (value) =>
                            setDialogState(() => activeBorderAlpha = value),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                            "setting.class_table_style_page.active_inner_alpha",
                          translationParams: {
                            "value": _formatPercent(activeInnerAlpha),
                          },
                        ),
                      ),
                      Slider(
                        value: activeInnerAlpha,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        onChanged: (value) =>
                            setDialogState(() => activeInnerAlpha = value),
                      ),
                      if (completedEnabled) ...[
                        const Divider(height: 24),
                        Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.completed_section",
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.completed_saturation_factor",
                            translationParams: {
                              "value": _formatPercent(
                                completedSaturationFactor,
                              ),
                            },
                          ),
                        ),
                        Slider(
                          value: completedSaturationFactor,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          onChanged: (value) => setDialogState(
                            () => completedSaturationFactor = value,
                          ),
                        ),
                        Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.completed_brightness_factor",
                            translationParams: {
                              "value": _formatPercent(
                                completedBrightnessFactor,
                              ),
                            },
                          ),
                        ),
                        Slider(
                          value: completedBrightnessFactor,
                          min: 0.5,
                          max: 1.0,
                          divisions: 10,
                          onChanged: (value) => setDialogState(
                            () => completedBrightnessFactor = value,
                          ),
                        ),
                        Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.completed_text_saturation_factor",
                            translationParams: {
                              "value": _formatPercent(
                                completedTextSaturationFactor,
                              ),
                            },
                          ),
                        ),
                        Slider(
                          value: completedTextSaturationFactor,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          onChanged: (value) => setDialogState(
                            () => completedTextSaturationFactor = value,
                          ),
                        ),
                        Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.completed_border_alpha",
                            translationParams: {
                              "value": _formatPercent(completedBorderAlpha),
                            },
                          ),
                        ),
                        Slider(
                          value: completedBorderAlpha,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          onChanged: (value) => setDialogState(
                            () => completedBorderAlpha = value,
                          ),
                        ),
                        Text(
                          FlutterI18n.translate(
                            context,
                            "setting.class_table_style_page.completed_inner_alpha",
                            translationParams: {
                              "value": _formatPercent(completedInnerAlpha),
                            },
                          ),
                        ),
                        Slider(
                          value: completedInnerAlpha,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          onChanged: (value) =>
                              setDialogState(() => completedInnerAlpha = value),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(FlutterI18n.translate(context, "cancel")),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(FlutterI18n.translate(context, "confirm")),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (!shouldApply || !mounted) {
      return;
    }

    CompletedClassStyleConfig.completedEnabled = completedEnabled;
    CompletedClassStyleConfig.activeBrightnessFactor = activeBrightnessFactor
        .clamp(0.5, 1.0)
        .toDouble();
    CompletedClassStyleConfig.activeBorderAlpha = activeBorderAlpha;
    CompletedClassStyleConfig.activeInnerAlpha = activeInnerAlpha;
    CompletedClassStyleConfig.completedSaturationFactor =
        completedSaturationFactor;
    CompletedClassStyleConfig.completedBrightnessFactor =
        completedBrightnessFactor.clamp(0.5, 1.0).toDouble();
    CompletedClassStyleConfig.completedTextSaturationFactor =
        completedTextSaturationFactor;
    CompletedClassStyleConfig.completedBorderAlpha = completedBorderAlpha;
    CompletedClassStyleConfig.completedInnerAlpha = completedInnerAlpha;
    await CompletedClassStyleConfig.saveToPreference();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ClassTableState.of(context)!.controllers;
    final hasError =
        state.errorWithoutCacheSources.isNotEmpty ||
        state.errorWithCacheSources.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "classtable.page_title")),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          if (hasError)
            IconButton(
              onPressed: _showLoadErrorDialog,
              icon: const Icon(Icons.error_outline),
              tooltip: FlutterI18n.translate(context, "load_error"),
            ),
          /// While collapsed, the week number is all that is left of the bar.
          if (_weekBarCollapsed) _weekChip(),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                value: 'A',
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.popup_menu.not_arranged",
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'B',
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.popup_menu.class_changed",
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'C',
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.popup_menu.add_class",
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'D',
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.popup_menu.generate_ical",
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'H',
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.popup_menu.output_to_system",
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'I',
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.popup_menu.refresh_classtable",
                  ),
                ),
              ),
            ],
            onSelected: (String action) async {
              switch (action) {
                case 'A':
                  var notArranged = ClassTableState.of(
                    context,
                  )!.controllers.notArranged;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return NotArrangedClassList(notArranged: notArranged);
                      },
                    ),
                  );
                  break;
                case 'B':
                  var classChange = ClassTableState.of(
                    context,
                  )!.controllers.classChange;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ClassChangeList(classChanges: classChange);
                      },
                    ),
                  );
                  break;
                case 'C':
                  int semesterLength = ClassTableState.of(
                    context,
                  )!.controllers.semesterLength;
                  dynamic data = await Navigator.of(context).push<dynamic>(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ClassAddWindow(semesterLength: semesterLength);
                      },
                    ),
                  );
                  if (context.mounted && data != null) {
                    if (data is CustomClass) {
                      await ClassTableState.of(
                        context,
                      )!.controllers.addCustomClass(data);
                    }
                  }
                  break;
                case 'D':
                  try {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          FlutterI18n.translate(
                            context,
                            "classtable.partner_classtable.share_dialog.title",
                          ),
                        ),
                        content: Text(
                          FlutterI18n.translate(
                            context,
                            "classtable.partner_classtable.share_dialog.content",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              FlutterI18n.translate(context, "confirm"),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (context.mounted) {
                      String fileName =
                          "classtable-"
                          "${DateFormat("yyyyMMddTHHmmss").format(DateTime.now())}-"
                          "${classTableState.semesterCode}"
                          ".ics";
                      //  if (Platform.isLinux ||
                      //      Platform.isMacOS ||
                      //      Platform.isWindows) {
                      await FilePicker.saveFile(
                        dialogTitle: FlutterI18n.translate(
                          context,
                          "classtable.partner_classtable.save_dialog.title",
                        ),
                        fileName: fileName,
                        allowedExtensions: ["ics"],
                        bytes: Uint8List.fromList(
                          utf8.encode(classTableState.iCalenderStr),
                        ),
                        windowsOptions: WindowsOptions(lockParentWindow: true),
                        linuxOptions: LinuxOptions(lockParentWindow: true),
                      );
                      //  } else {
                      //    String tempPath = await getTemporaryDirectory().then(
                      //      (value) => value.path,
                      //    );
                      //    File file = File("$tempPath/$fileName");
                      //    if (!(await file.exists())) {
                      //      await file.create();
                      //    }
                      //    await file.writeAsString(classTableState.iCalenderStr);
                      //   await SharePlus.instance.share(
                      //    ShareParams(
                      //        files: [XFile("$tempPath/$fileName")],
                      //        sharePositionOrigin:
                      //            box!.localToGlobal(Offset.zero) & box.size,
                      //     ),
                      //  );

                      //    await file.delete();
                    }
                    //}
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: FlutterI18n.translate(
                          context,
                          "classtable.partner_classtable.save_dialog.success_message",
                        ),
                      );
                    }
                  } on FileSystemException {
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: FlutterI18n.translate(
                          context,
                          "classtable.partner_classtable.save_dialog.failure_message",
                        ),
                      );
                    }
                  }
                  break;
                case 'H':
                  await classTableState
                      .outputToCalendar(() async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              FlutterI18n.translate(
                                context,
                                "classtable.output_to_system.request_all_title",
                              ),
                            ),
                            content: Text(
                              FlutterI18n.translate(
                                context,
                                "classtable.output_to_system.request_all",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  FlutterI18n.translate(context, "confirm"),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .then((data) {
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: FlutterI18n.translate(
                              context,
                              data
                                  ? "classtable.output_to_system.success"
                                  : "classtable.output_to_system.failure",
                            ),
                          );
                        }
                      });
                case 'I':
                  bool isAccepted =
                      await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(
                            FlutterI18n.translate(
                              context,
                              "setting.class_refresh_title",
                            ),
                          ),
                          content: Text(
                            FlutterI18n.translate(
                              context,
                              "setting.class_refresh_content",
                            ),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                FlutterI18n.translate(context, "cancel"),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                FlutterI18n.translate(context, "confirm"),
                              ),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (context.mounted && isAccepted) {
                    await classTableState.updateClasstable(context).then((
                      data,
                    ) {
                      if (context.mounted) {
                        showToast(
                          context: context,
                          msg: FlutterI18n.translate(
                            context,
                            "classtable.refresh_classtable.success",
                          ),
                        );
                      }
                    });
                  }
                  break;
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// The wallpaper. It spans the whole body, under the week bar as well as the table, and it
          /// is never blurred itself: every frosted control blurs its own copy of it inside its own
          /// bounds.
          DecoratedBox(decoration: decoration),

          /// The page. While the bar floats it starts at the top and the bar covers it; once the bar
          /// is pinned it slides down to leave the bar a strip of its own.
          AnimatedPositioned(
            left: 0,
            right: 0,
            top: _weekBarCollapsed ? 0 : _weekBarHeight,
            bottom: 0,
            duration: weekBarDockDuration,
            curve: Curves.easeOutCubic,
            child: NotificationListener<ScrollNotification>(
              /// Dragging the table puts the floating bar away, so it does not sit on top of a
              /// table the user is trying to reach.
              ///
              /// Only a drag counts. Picking a week from the bar itself pages the table over an
              /// animation, and that is not a reason to close the bar the user is working in: it
              /// stays out until they put it away themselves.
              onNotification: (ScrollNotification notification) {
                final bool dragStarted =
                    notification is ScrollStartNotification &&
                    notification.dragDetails != null;
                if (dragStarted && _weekBarCollapsed && _weekBarExpanded) {
                  setState(() => _weekBarExpanded = false);
                }
                return false;
              },
              /// Everything above the wallpaper that wants a frosted background shares one blur of
              /// it: the status banner and every control in the table.
              child: BackdropGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClassTableInlineBanner(
                      loadingSources: state.loadingSources,
                      cacheSources: state.cacheSources,
                    ),
                    ClassTableSheet(
                      singleIndex: classTableState.chosenWeek,
                      pageControl: pageControl,
                      semesterLength: classTableState.semesterLength,
                      onPageChanged: _onPageChanged,
                    ).expanded(),
                  ],
                ),
              ),
            ),
          ),

          /// Tapping anywhere else puts the floating bar away.
          ///
          /// Kept mounted even while closed and merely ignored, because a conditionally present
          /// sibling shifts the bar along the Stack's children list: Flutter would then treat the bar
          /// as a brand new element and the implicit animations below would jump straight to their
          /// new values instead of running.
          ///
          /// `translucent`, not `opaque`: opaque would swallow the drag as well as the tap and leave
          /// the table unscrollable while the bar is open. Being hit first still lets this layer win
          /// the tap, so a tap on a class card does not open it.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !(_weekBarCollapsed && _weekBarExpanded),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _weekBarExpanded = false),
              ),
            ),
          ),

          /// The bar itself, one element for both modes.
          ///
          /// Collapsed it is inset, rounded and shadowed so it reads as floating over the table;
          /// pinned it grows to the full width, squares off and drops its shadow as it docks. The
          /// page above follows a slightly longer curve, so the bar visibly settles first and the
          /// table then takes its place.
          AnimatedPositioned(
            left: _weekBarFloating ? timeLineInset : 0,
            right: _weekBarFloating ? timeLineInset : 0,
            top: _weekBarFloating ? timeLineInset : 0,
            height: _weekBarHeight,
            duration: weekBarPopDuration,
            curve: Curves.easeOutCubic,
            child: IgnorePointer(
              ignoring: !_weekBarVisible,
              child: AnimatedSlide(
                offset: _weekBarVisible ? Offset.zero : const Offset(0, -1),
                duration: weekBarPopDuration,
                curve: Curves.easeOutCubic,
                child: AnimatedScale(
                  scale: _weekBarVisible ? 1.0 : 0.96,
                  alignment: Alignment.topCenter,
                  duration: weekBarPopDuration,
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: weekBarPopDuration,
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          _weekBarFloating ? timeLineRadius : 0,
                        ),
                        boxShadow: _weekBarFloating
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: timeLineShadowAlpha,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    child: Stack(
                      children: [
                          /// Frosted, like the panels in the table: the bar's own background blurs
                          /// the wallpaper behind it while the wallpaper itself stays sharp.
                          ///
                          /// The tint is the filter's child, not a colour under it, so what gets
                          /// blurred is the raw wallpaper — the same order the class cards use.
                          ///
                          /// Keep the filter mounted throughout the pop so the backdrop is blurred
                          /// from the first frame rather than appearing only after the bar settles.
                          Positioned.fill(
                            child: GlassBlur(
                              borderRadius: BorderRadius.circular(
                                _weekBarFloating ? timeLineRadius : 0,
                              ),
                              child: ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh
                                    .withValues(alpha: weekBarSurfaceAlpha),
                              ),
                            ),
                          ),
                          /// Taps on the bar's own body keep it open: putting it away is for taps
                          /// outside it. Translucent rather than opaque, so a drag that starts on
                          /// the bar still reaches the table underneath.
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {},
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: _weekBarVisible ? 1.0 : 0.0,
                            duration: weekBarPopDuration,
                            curve: Curves.easeOut,
                            child: _weekBarContents(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Keeps [classTableState.chosenWeek] in step with the week pages.
  void _onPageChanged(int value) {
    /// When [pageControl.animateTo] triggered,
    /// page view will try to refresh the [chosenWeek] everytime the page
    /// view changed into a new page. Because animateTo will load every page
    /// it passed.
    ///
    /// So that's the [isTopRowLocked] is used for. When week choice row is
    /// locked, it will not refresh the [chosenWeek]. And when [chosenWeek]
    /// is equal to the current page, unlock the [isTopRowLocked].
    if (isTopRowLocked == false) {
      /// Flagged so [_switchPage] leaves the table to finish its own gesture instead of animating
      /// a page the user is still dragging. The row is repositioned after the page settles.
      _chosenWeekFromTable = true;
      try {
        classTableState.chosenWeek = value;
      } finally {
        _chosenWeekFromTable = false;
      }
    }
  }
}
