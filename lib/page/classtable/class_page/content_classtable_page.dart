// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_page/class_change_list.dart';
import 'package:watermeter/page/classtable/class_page/classtable_inline_banner.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/class_page/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/class_page/week_choice_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:share_plus/share_plus.dart';

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
  late PageController rowControl;

  late BoxDecoration decoration;
  late ClassTableWidgetState classTableState;
  ClassTableWidgetState? _attachedClassTableState;

  void _switchPage() {
    if (!mounted) {
      return;
    }
    setState(() => isTopRowLocked = true);
    Future.wait([
      rowControl.animateToPage(
        classTableState.chosenWeek,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: changePageTime),
      ),
      pageControl.animateToPage(
        classTableState.chosenWeek,
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: changePageTime),
      ),
    ]).then((value) {
      if (mounted) {
        isTopRowLocked = false;
      }
    });
  }

  @override
  void dispose() {
    _attachedClassTableState?.removeListener(_switchPage);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final nextClassTableState = ClassTableState.of(context)!.controllers;

    if (_attachedClassTableState != nextClassTableState) {
      _attachedClassTableState?.removeListener(_switchPage);
      _attachedClassTableState = nextClassTableState;
      _attachedClassTableState!.addListener(_switchPage);
    }

    classTableState = nextClassTableState;

    pageControl = PageController(
      initialPage: classTableState.chosenWeek,
      keepPage: true,
    );

    /// (weekButtonWidth + 2 * weekButtonHorizontalPadding)
    /// is the width of the week choose button.
    rowControl = PageController(
      initialPage: classTableState.chosenWeek,
      viewportFraction:
          (weekButtonWidth + 2 * weekButtonHorizontalPadding) /
          ClassTableState.of(context)!.constraints.minWidth,
      keepPage: true,
    );

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
  Widget _topView() {
    return SizedBox(
      /// Related to the overview of the week.
      height: MediaQuery.sizeOf(context).height >= 500
          ? topRowHeightBig
          : topRowHeightSmall,

      child: Container(
        padding: const EdgeInsets.only(top: 2, bottom: 4),
        color: Theme.of(context).colorScheme.surface,
        child: PageView.builder(
          padEnds: false,
          controller: rowControl,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: classTableState.semesterLength,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: weekButtonHorizontalPadding,
              ),
              child: SizedBox(
                width: weekButtonWidth,
                child: Card(
                  color: Theme.of(context).highlightColor.withValues(
                    alpha: classTableState.chosenWeek == index ? 0.3 : 0.0,
                  ),
                  elevation: 0.0,
                  child: InkWell(
                    /// The following themes are the same as the Material 3 Card Radius.
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
              ),
            );
          },
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

  Future<void> _showClassTableVisualSettingsDialog() async {
    var enabled = CurrentTimeIndicatorConfig.enabled;
    var showTimeLabel = CurrentTimeIndicatorConfig.showTimeLabel;
    var showTodayColumnHighlight =
        CurrentTimeIndicatorConfig.showTodayColumnHighlight;
    var activeBorderAlpha = CompletedClassStyleConfig.activeBorderAlpha;
    var activeInnerAlpha = CompletedClassStyleConfig.activeInnerAlpha;
    var completedSaturationFactor =
        CompletedClassStyleConfig.completedSaturationFactor;
    var completedTextSaturationFactor =
        CompletedClassStyleConfig.completedTextSaturationFactor;
    var completedBorderAlpha = CompletedClassStyleConfig.completedBorderAlpha;
    var completedInnerAlpha = CompletedClassStyleConfig.completedInnerAlpha;

    String formatPercent(double value) => "${(value * 100).round()}%";

    final shouldApply =
        await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "classtable.visual_settings.title",
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.current_time_section",
                        ),
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          FlutterI18n.translate(
                            context,
                            "classtable.visual_settings.show_current_time_indicator",
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
                            "classtable.visual_settings.show_current_time_label",
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
                            "classtable.visual_settings.show_today_column_highlight",
                          ),
                        ),
                        value: showTodayColumnHighlight,
                        onChanged: (value) => setDialogState(
                          () => showTodayColumnHighlight = value,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.unfinished_section",
                        ),
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.active_border_alpha",
                          translationParams: {
                            "value": formatPercent(activeBorderAlpha),
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
                          "classtable.visual_settings.active_inner_alpha",
                          translationParams: {
                            "value": formatPercent(activeInnerAlpha),
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
                      const Divider(height: 24),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.completed_section",
                        ),
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.completed_saturation_factor",
                          translationParams: {
                            "value": formatPercent(completedSaturationFactor),
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
                          "classtable.visual_settings.completed_text_saturation_factor",
                          translationParams: {
                            "value": formatPercent(
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
                          "classtable.visual_settings.completed_border_alpha",
                          translationParams: {
                            "value": formatPercent(completedBorderAlpha),
                          },
                        ),
                      ),
                      Slider(
                        value: completedBorderAlpha,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        onChanged: (value) =>
                            setDialogState(() => completedBorderAlpha = value),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.completed_inner_alpha",
                          translationParams: {
                            "value": formatPercent(completedInnerAlpha),
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
    CompletedClassStyleConfig.activeBorderAlpha = activeBorderAlpha;
    CompletedClassStyleConfig.activeInnerAlpha = activeInnerAlpha;
    CompletedClassStyleConfig.completedSaturationFactor =
        completedSaturationFactor;
    CompletedClassStyleConfig.completedTextSaturationFactor =
        completedTextSaturationFactor;
    CompletedClassStyleConfig.completedBorderAlpha = completedBorderAlpha;
    CompletedClassStyleConfig.completedInnerAlpha = completedInnerAlpha;
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
        leading: BackButton(
          onPressed: () =>
              Navigator.of(ClassTableState.of(context)!.parentContext).pop(),
        ),
        actions: [
          if (hasError)
            IconButton(
              onPressed: _showLoadErrorDialog,
              icon: const Icon(Icons.error_outline),
              tooltip: FlutterI18n.translate(context, "load_error"),
            ),
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
              PopupMenuItem<String>(
                value: 'J',
                child: Text(
                  FlutterI18n.translate(
                    context,
                    "classtable.popup_menu.visual_settings",
                  ),
                ),
              ),
            ],
            onSelected: (String action) async {
              final box = context.findRenderObject() as RenderBox?;
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
                  (ClassDetail, TimeArrangement)? data =
                      await Navigator.of(
                        context,
                      ).push<(ClassDetail, TimeArrangement)>(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return ClassAddWindow(
                              semesterLength: semesterLength,
                            );
                          },
                        ),
                      );
                  if (context.mounted && data != null) {
                    await ClassTableState.of(
                      context,
                    )!.controllers.addUserDefinedClass(data.$1, data.$2);
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
                      if (Platform.isLinux ||
                          Platform.isMacOS ||
                          Platform.isWindows) {
                        String?
                        resultFilePath = await FilePicker.platform.saveFile(
                          dialogTitle: FlutterI18n.translate(
                            context,
                            "classtable.partner_classtable.save_dialog.title",
                          ),
                          fileName: fileName,
                          allowedExtensions: ["ics"],
                          lockParentWindow: true,
                        );
                        if (resultFilePath != null) {
                          File file = File(resultFilePath);
                          if (!(await file.exists())) {
                            await file.create();
                          }
                          await file.writeAsString(
                            classTableState.iCalenderStr,
                          );
                        }
                      } else {
                        String tempPath = await getTemporaryDirectory().then(
                          (value) => value.path,
                        );
                        File file = File("$tempPath/$fileName");
                        if (!(await file.exists())) {
                          await file.create();
                        }
                        await file.writeAsString(classTableState.iCalenderStr);
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile("$tempPath/$fileName")],
                            sharePositionOrigin:
                                box!.localToGlobal(Offset.zero) & box.size,
                          ),
                        );

                        await file.delete();
                      }
                    }
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
                case 'J':
                  await _showClassTableVisualSettingsDialog();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).height >= 500
                  ? topRowHeightBig
                  : topRowHeightSmall,
            ),
            child: _topView(),
          ),
          ClassTableInlineBanner(
            loadingSources: state.loadingSources,
            cacheSources: state.cacheSources,
          ),
          DecoratedBox(
            decoration: decoration,
            child: _classTablePage(),
          ).expanded(),
        ],
      ),
    );
  }

  /// The [_classTablePage] is controlled by [pageControl].
  Widget _classTablePage() => PageView.builder(
    scrollDirection: Axis.horizontal,
    controller: pageControl,
    onPageChanged: (value) {
      /// When [pageControl.animateTo] triggered,
      /// page view will try to refresh the [chosenWeek] everytime the page
      /// view changed into a new page. Because animateTo will load every page
      /// it passed.
      ///
      /// So that's the [isTopRowLocked] is used for. When week choice row is
      /// locked, it will not refresh the [chosenWeek]. And when [chosenWeek]
      /// is equal to the current page, unlock the [isTopRowLocked].
      if (isTopRowLocked == false) {
        classTableState.chosenWeek = value;
      }
    },
    itemCount: classTableState.semesterLength,
    itemBuilder: (context, index) => LayoutBuilder(
      builder: (context, constraint) =>
          ClassTableView(constraint: constraint, index: index),
    ),
  );
}
