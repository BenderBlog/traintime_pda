// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show BlurStyle, ImageFilter, MaskFilter;

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:intl/intl.dart';

import 'package:styled_widget/styled_widget.dart';
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
  late PageController rowControl;

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

    super.didChangeDependencies();
  }

  /// Padding which keeps the classtable sheet away from the edges of the
  /// display.
  ///
  /// The sheet is scrollable down to its very last row, and the bottom of the
  /// screen is where the system navigation bar and the rounded corners of the
  /// display are. Both are honoured here, so the last block of the day (the
  /// time of the 11th class) stays readable.
  EdgeInsets _sheetSafeInsets(BuildContext context) {
    /// `padding` already has the top inset of the app bar taken out, while
    /// `viewPadding` keeps the real size of the system bars. The bottom one
    /// has to come from `viewPadding`, otherwise the sheet would crawl under
    /// the navigation bar whenever the keyboard is around.
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);

    /// The sheet does not reach the edges of the display, so the corner of the
    /// screen only reaches in about half of its radius where the sheet starts.
    /// Keeping the whole radius free left a lot of empty room on devices with
    /// round corners, so only half of it is kept, within sane limits.
    ///
    /// The radii come from [MediaQuery.displayCornerRadiiOf], which the platform
    /// fills in on Android 12 and later and leaves null everywhere else. Reading
    /// them there also means this page is rebuilt whenever they change, so the
    /// window does not have to be watched by hand.
    final corners = MediaQuery.displayCornerRadiiOf(context);
    final cornerRadius = math.max(
      corners?.bottomLeft.y ?? 0,
      corners?.bottomRight.y ?? 0,
    );
    final cornerInset = math.min(
      math.max(cornerRadius / 2, classTableMinimumBottomInset),
      classTableMaximumBottomInset,
    );
    return EdgeInsets.fromLTRB(
      padding.left + classTableSheetMargin,
      padding.top + classTableSheetMargin,
      padding.right + classTableSheetMargin,
      math.max(viewPadding.bottom, cornerInset) + classTableSheetMargin,
    );
  }

  /// The user defined background image, blurred as configured.
  Widget _backgroundLayer(BuildContext context) {
    if (!preference.getBool(preference.Preference.decorated)) {
      return const SizedBox.shrink();
    }

    final image = File("${supportPath.path}/${classTableState.decorationName}");
    if (!image.existsSync()) {
      return const SizedBox.shrink();
    }

    final viewport = MediaQuery.sizeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (math.max(viewport.width, viewport.height) * pixelRatio)
        .round()
        .clamp(1, 2560)
        .toInt();
    final imageRevision =
        "${image.lengthSync()}:${image.lastModifiedSync().microsecondsSinceEpoch}";

    final blur = preference
        .getDouble(preference.Preference.classTableBackgroundBlur)
        .clamp(0.0, maxClassTableBackgroundBlur)
        .toDouble();

    Widget layer = Image.file(
      image,
      key: ValueKey("${image.path}:$imageRevision"),
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      opacity: AlwaysStoppedAnimation<double>(
        Theme.of(context).brightness == Brightness.dark ? 0.4 : 1.0,
      ),
    );

    if (blur > 0) {
      /// Blurring pulls in the pixels outside of the image, which would leave
      /// the edges translucent. The image is scaled up a little to make sure
      /// the whole background stays covered.
      layer = ClipRect(
        child: Transform.scale(
          scale: 1 + blur / 50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.clamp,
            ),
            child: layer,
          ),
        ),
      );
    }

    return Positioned.fill(child: layer);
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
        context.t.resolveKey(switch (source) {
          ClassTableStatusSource.classTable =>
            "classtable.status_source.class_table",
          ClassTableStatusSource.exam => "classtable.status_source.exam",
          ClassTableStatusSource.physicsExperiment =>
            "classtable.status_source.physics_experiment",
          ClassTableStatusSource.otherExperiment =>
            "classtable.status_source.other_experiment",
        });

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
        context.t.classtable.statusBanner.errorSummary(
          sources: errorWithoutCacheSources.map(sourceLabel).join("、"),
        ),
      ...errorWithoutCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(context.t)
            : context.t.common.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
      if (errorWithoutCacheSources.isNotEmpty &&
          errorWithCacheSources.isNotEmpty)
        "",
      if (errorWithCacheSources.isNotEmpty)
        context.t.classtable.statusBanner.cache(
          sources: errorWithCacheSources.map(sourceLabel).join("、"),
        ),
      ...errorWithCacheSources.map((source) {
        final hintKey = sourceHintKey(source);
        final detail = hintKey != null
            ? hintKey.resolve(context.t)
            : context.t.common.networkError;
        return "${sourceLabel(source)}: $detail";
      }),
    ].join("\n");

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.classtable.errorDialogTitle),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.confirm),
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
                context.t.setting.classTableStylePage.currentTimeSettingsTitle,
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
                          context
                              .t
                              .setting
                              .classTableStylePage
                              .showCurrentTimeIndicator,
                        ),
                        value: enabled,
                        onChanged: (value) =>
                            setDialogState(() => enabled = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context
                              .t
                              .setting
                              .classTableStylePage
                              .showCurrentTimeLabel,
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
                          context
                              .t
                              .setting
                              .classTableStylePage
                              .showTodayColumnHighlight,
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
                  child: Text(context.t.common.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.t.common.confirm),
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
                context.t.setting.classTableStylePage.classColorSettingsTitle,
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
                          context
                              .t
                              .setting
                              .classTableStylePage
                              .completedStyleEnabled,
                        ),
                        value: completedEnabled,
                        onChanged: (value) =>
                            setDialogState(() => completedEnabled = value),
                      ),
                      const Divider(height: 24),
                      Text(
                        context.t.setting.classTableStylePage.unfinishedSection,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        context.t.setting.classTableStylePage
                            .activeBrightnessFactor(
                              value: _formatPercent(activeBrightnessFactor),
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
                        context.t.setting.classTableStylePage.activeBorderAlpha(
                          value: _formatPercent(activeBorderAlpha),
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
                        context.t.setting.classTableStylePage.activeInnerAlpha(
                          value: _formatPercent(activeInnerAlpha),
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
                          context
                              .t
                              .setting
                              .classTableStylePage
                              .completedSection,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          context.t.setting.classTableStylePage
                              .completedSaturationFactor(
                                value: _formatPercent(
                                  completedSaturationFactor,
                                ),
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
                          context.t.setting.classTableStylePage
                              .completedBrightnessFactor(
                                value: _formatPercent(
                                  completedBrightnessFactor,
                                ),
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
                          context.t.setting.classTableStylePage
                              .completedTextSaturationFactor(
                                value: _formatPercent(
                                  completedTextSaturationFactor,
                                ),
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
                          context.t.setting.classTableStylePage
                              .completedBorderAlpha(
                                value: _formatPercent(completedBorderAlpha),
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
                          context.t.setting.classTableStylePage
                              .completedInnerAlpha(
                                value: _formatPercent(completedInnerAlpha),
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
                  child: Text(context.t.common.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.t.common.confirm),
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
        title: Text(context.t.classtable.pageTitle),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          if (hasError)
            IconButton(
              onPressed: _showLoadErrorDialog,
              icon: const Icon(Icons.error_outline),
              tooltip: context.t.classtable.errorDialogTitle,
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                value: 'A',
                child: Text(context.t.classtable.popupMenu.notArranged),
              ),
              PopupMenuItem<String>(
                value: 'B',
                child: Text(context.t.classtable.popupMenu.classChanged),
              ),
              PopupMenuItem<String>(
                value: 'C',
                child: Text(context.t.classtable.popupMenu.addClass),
              ),
              PopupMenuItem<String>(
                value: 'D',
                child: Text(context.t.classtable.popupMenu.generateIcal),
              ),
              PopupMenuItem<String>(
                value: 'H',
                child: Text(context.t.classtable.popupMenu.outputToSystem),
              ),
              PopupMenuItem<String>(
                value: 'I',
                child: Text(context.t.classtable.popupMenu.refreshClasstable),
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
                          context
                              .t
                              .classtable
                              .partnerClasstable
                              .shareDialog
                              .title,
                        ),
                        content: Text(
                          context
                              .t
                              .classtable
                              .partnerClasstable
                              .shareDialog
                              .content,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(context.t.common.confirm),
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
                        dialogTitle: context
                            .t
                            .classtable
                            .partnerClasstable
                            .saveDialog
                            .title,
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
                        msg: context
                            .t
                            .classtable
                            .partnerClasstable
                            .saveDialog
                            .successMessage,
                      );
                    }
                  } on FileSystemException {
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: context
                            .t
                            .classtable
                            .partnerClasstable
                            .saveDialog
                            .failureMessage,
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
                              context
                                  .t
                                  .classtable
                                  .outputToSystem
                                  .requestAllTitle,
                            ),
                            content: Text(
                              context.t.classtable.outputToSystem.requestAll,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(context.t.common.confirm),
                              ),
                            ],
                          ),
                        );
                      })
                      .then((data) {
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: context.t.resolveKey(
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
                          title: Text(context.t.setting.classRefreshTitle),
                          content: Text(context.t.setting.classRefreshContent),
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
                              child: Text(context.t.common.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.t.common.confirm),
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
                          msg: context.t.classtable.refreshClasstable.success,
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
      body: Builder(
        /// The safe area has to be measured below the app bar: the insets of
        /// the context above the scaffold still contain the status bar the app
        /// bar has already taken care of.
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            /// The background image is drawn behind everything, so the
            /// decorated area still reaches the edges of the screen while the
            /// sheet below respects the safe area.
            _backgroundLayer(context),
            Column(
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
                _sheet(context).expanded(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The sheet of the classtable: it is kept inside the safe area of the
  /// display and gets rounded corners of its own, since it does not reach the
  /// edges of the screen any more.
  ///
  /// A shadow drawn only outside of it, plus a hairline around it, lift it off
  /// the screen, so the table reads as one card floating over the picture and
  /// the room kept below it reads as the margin of that card instead of a gap.
  ///
  /// The picture itself is left alone: a colour laid over it would hide the
  /// background image, and blurring it here would only repeat what the
  /// background blur already does.
  Widget _sheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(classTableSheetRadius);
    return Padding(
      padding: _sheetSafeInsets(context),
      child: Stack(
        /// 阴影要画到面板外面去，所以这一层不能裁。
        clipBehavior: Clip.none,
        children: [
          /// 阴影单独一层，而且**只画面板外侧**：面板本身是透明的，
          /// 用普通的 BoxShadow 会在面板内部透出来一圈黑。
          Positioned.fill(
            child: CustomPaint(
              painter: _SheetShadowPainter(
                radius: classTableSheetRadius,
                sigma: classTableSheetShadowSigma,
                color: scheme.shadow.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              /// 紧贴着边缘描一圈极细的线：花壁纸上只靠阴影，边角是"站不住"的。
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: LayoutBuilder(
                  /// The table measures itself against the room which is really
                  /// left for it, instead of the whole window.
                  builder: (context, constraints) => ClassTableState(
                    constraints: constraints,
                    controllers: classTableState,
                    child: _classTablePage(),
                  ),
                ),
              ),
            ),
          ),
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

/// 画课表面板外侧的一圈阴影。
///
/// 面板里面是透的（能看见壁纸），所以不能直接用 `BoxShadow` —— 它的模糊会从
/// 面板内部透出来，看着就是"里面一圈黑"。这里先把面板那块从画布上挖掉，
/// 再画模糊的圆角矩形，于是只有外侧那一圈留下来。
class _SheetShadowPainter extends CustomPainter {
  const _SheetShadowPainter({
    required this.radius,
    required this.sigma,
    required this.color,
  });

  final double radius;
  final double sigma;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(box, Radius.circular(radius));

    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(box.inflate(sigma * 4)),
        Path()..addRRect(rrect),
      ),
      doAntiAlias: true,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
    );
  }

  @override
  bool shouldRepaint(covariant _SheetShadowPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.sigma != sigma ||
      oldDelegate.color != color;
}
