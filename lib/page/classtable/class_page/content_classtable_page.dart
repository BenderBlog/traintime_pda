// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
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
import 'package:watermeter/generated/l10n.dart';

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
  bool _isListening = false;
  bool _didLoadVisualSettings = false;

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
    classTableState.removeListener(_switchPage);
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
      _isListening = true;
    }

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
      switch (source) {
        ClassTableStatusSource.classTable => I18n.of(
          context,
        )!.classtableStatusSourceClassTable,
        ClassTableStatusSource.exam => I18n.of(
          context,
        )!.classtableStatusSourceExam,
        ClassTableStatusSource.physicsExperiment => I18n.of(
          context,
        )!.classtableStatusSourcePhysicsExperiment,
        ClassTableStatusSource.otherExperiment => I18n.of(
          context,
        )!.classtableStatusSourceOtherExperiment,
      };

    CacheHint? sourceHintKey(ClassTableStatusSource source) => switch (source) {
      ClassTableStatusSource.classTable => state.classTableCacheHintKey,
      ClassTableStatusSource.exam => state.examCacheHintKey,
      ClassTableStatusSource.physicsExperiment =>
        state.physicsExperimentCacheHintKey,
      ClassTableStatusSource.otherExperiment =>
        state.otherExperimentCacheHintKey,
    };

    final content = <String>[
      if (errorWithoutCacheSources.isNotEmpty)
        I18n.of(context)!.classtableStatusBannerErrorSummary(errorWithoutCacheSources.map(sourceLabel).join("、")),
      ...errorWithoutCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(I18n.of(context)!)
            : I18n.of(context)!.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
      if (errorWithoutCacheSources.isNotEmpty &&
          errorWithCacheSources.isNotEmpty)
        "",
      if (errorWithCacheSources.isNotEmpty)
        I18n.of(context)!.classtableStatusBannerCache(errorWithCacheSources.map(sourceLabel).join("、")),
      ...errorWithCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(I18n.of(context)!)
            : I18n.of(context)!.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
    ].join("\n");

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          I18n.of(context)!.classtableErrorDialogTitle,
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(I18n.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  String _formatPercent(double value) => "${(value * 100).round()}%";

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
                I18n.of(context)!.classtableVisualSettingsCurrentTimeSettingsTitle,
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
                          I18n.of(context)!.classtableVisualSettingsShowCurrentTimeIndicator,
                        ),
                        value: enabled,
                        onChanged: (value) =>
                            setDialogState(() => enabled = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          I18n.of(context)!.classtableVisualSettingsShowCurrentTimeLabel,
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
                          I18n.of(context)!.classtableVisualSettingsShowTodayColumnHighlight,
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
                  child: Text(I18n.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(I18n.of(context)!.confirm),
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
                I18n.of(context)!.classtableVisualSettingsClassColorSettingsTitle,
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
                          I18n.of(context)!.classtableVisualSettingsCompletedStyleEnabled,
                        ),
                        value: completedEnabled,
                        onChanged: (value) =>
                            setDialogState(() => completedEnabled = value),
                      ),
                      const Divider(height: 24),
                      Text(
                        I18n.of(context)!.classtableVisualSettingsUnfinishedSection,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        I18n.of(context)!.classtableVisualSettingsActiveBrightnessFactor(_formatPercent(activeBrightnessFactor)),
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
                        I18n.of(context)!.classtableVisualSettingsActiveBorderAlpha(_formatPercent(activeBorderAlpha)),
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
                        I18n.of(context)!.classtableVisualSettingsActiveInnerAlpha(_formatPercent(activeInnerAlpha)),
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
                          I18n.of(context)!.classtableVisualSettingsCompletedSection,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          I18n.of(context)!.classtableVisualSettingsCompletedSaturationFactor(_formatPercent(completedSaturationFactor).toString()),
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
                          I18n.of(context)!.classtableVisualSettingsCompletedBrightnessFactor(_formatPercent(completedBrightnessFactor).toString()),
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
                          I18n.of(context)!.classtableVisualSettingsCompletedTextSaturationFactor(_formatPercent(completedTextSaturationFactor).toString()),
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
                          I18n.of(context)!.classtableVisualSettingsCompletedBorderAlpha(_formatPercent(completedBorderAlpha)),
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
                          I18n.of(context)!.classtableVisualSettingsCompletedInnerAlpha(_formatPercent(completedInnerAlpha)),
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
                  child: Text(I18n.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(I18n.of(context)!.confirm),
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
        title: Text(I18n.of(context)!.classtablePageTitle),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          if (hasError)
            IconButton(
              onPressed: _showLoadErrorDialog,
              icon: const Icon(Icons.error_outline),
              tooltip: I18n.of(context)!.loadError,
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                value: 'A',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuNotArranged,
                ),
              ),
              PopupMenuItem<String>(
                value: 'B',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuClassChanged,
                ),
              ),
              PopupMenuItem<String>(
                value: 'C',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuAddClass,
                ),
              ),
              PopupMenuItem<String>(
                value: 'D',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuGenerateIcal,
                ),
              ),
              PopupMenuItem<String>(
                value: 'H',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuOutputToSystem,
                ),
              ),
              PopupMenuItem<String>(
                value: 'I',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuRefreshClasstable,
                ),
              ),
              PopupMenuItem<String>(
                value: 'J',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuCurrentTimeSettings,
                ),
              ),
              PopupMenuItem<String>(
                value: 'K',
                child: Text(
                  I18n.of(context)!.classtablePopupMenuClassColorSettings,
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
                          I18n.of(context)!.classtablePartnerClasstableShareDialogTitle,
                        ),
                        content: Text(
                          I18n.of(context)!.classtablePartnerClasstableShareDialogContent,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              I18n.of(context)!.confirm,
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
                        dialogTitle: I18n.of(context)!.classtablePartnerClasstableSaveDialogTitle,
                        fileName: fileName,
                        allowedExtensions: ["ics"],
                        bytes: Uint8List.fromList(
                          utf8.encode(classTableState.iCalenderStr),
                        ),
                        lockParentWindow: true,
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
                        msg: I18n.of(context)!.classtablePartnerClasstableSaveDialogSuccessMessage,
                      );
                    }
                  } on FileSystemException {
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: I18n.of(context)!.classtablePartnerClasstableSaveDialogFailureMessage,
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
                              I18n.of(context)!.classtableOutputToSystemRequestAllTitle,
                            ),
                            content: Text(
                              I18n.of(context)!.classtableOutputToSystemRequestAll,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  I18n.of(context)!.confirm,
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
                            msg: data
                                ? I18n.of(context)!.classtableOutputToSystemSuccess
                                : I18n.of(context)!.classtableOutputToSystemFailure,
                          );
                        }
                      });
                case 'I':
                  bool isAccepted =
                      await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(
                            I18n.of(context)!.settingClassRefreshTitle,
                          ),
                          content: Text(
                            I18n.of(context)!.settingClassRefreshContent,
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
                                I18n.of(context)!.cancel,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                I18n.of(context)!.confirm,
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
                          msg: I18n.of(context)!.classtableRefreshClasstableSuccess,
                        );
                      }
                    });
                  }
                  break;
                case 'J':
                  await _showCurrentTimeSettingsDialog();
                  break;
                case 'K':
                  await _showClassColorSettingsDialog();
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

