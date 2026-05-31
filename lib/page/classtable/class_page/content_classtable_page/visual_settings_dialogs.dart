// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

part of '../content_classtable_page.dart';

String _formatPercent(double value) => "${(value * 100).round()}%";

Future<bool> showCurrentTimeSettingsDialog(BuildContext context) async {
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
                "classtable.visual_settings.current_time_settings_title",
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

  if (!shouldApply || !context.mounted) {
    return false;
  }

  CurrentTimeIndicatorConfig.enabled = enabled;
  CurrentTimeIndicatorConfig.showTimeLabel = showTimeLabel;
  CurrentTimeIndicatorConfig.showTodayColumnHighlight =
      showTodayColumnHighlight;
  await CurrentTimeIndicatorConfig.saveToPreference();
  return true;
}

Future<bool> showClassColorSettingsDialog(BuildContext context) async {
  var completedEnabled = CompletedClassStyleConfig.completedEnabled;
  var activeBrightnessFactor = CompletedClassStyleConfig.activeBrightnessFactor
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
                "classtable.visual_settings.class_color_settings_title",
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
                          "classtable.visual_settings.completed_style_enabled",
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
                        "classtable.visual_settings.unfinished_section",
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      FlutterI18n.translate(
                        context,
                        "classtable.visual_settings.active_brightness_factor",
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
                      onChanged: (value) =>
                          setDialogState(() => activeBrightnessFactor = value),
                    ),
                    Text(
                      FlutterI18n.translate(
                        context,
                        "classtable.visual_settings.active_border_alpha",
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
                        "classtable.visual_settings.active_inner_alpha",
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
                          "classtable.visual_settings.completed_section",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.completed_saturation_factor",
                          translationParams: {
                            "value": _formatPercent(completedSaturationFactor),
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
                          "classtable.visual_settings.completed_brightness_factor",
                          translationParams: {
                            "value": _formatPercent(completedBrightnessFactor),
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
                          "classtable.visual_settings.completed_text_saturation_factor",
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
                          "classtable.visual_settings.completed_border_alpha",
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
                        onChanged: (value) =>
                            setDialogState(() => completedBorderAlpha = value),
                      ),
                      Text(
                        FlutterI18n.translate(
                          context,
                          "classtable.visual_settings.completed_inner_alpha",
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

  if (!shouldApply || !context.mounted) {
    return false;
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
  return true;
}
