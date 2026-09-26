// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/setting/class_table_preview.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';

class ClassTableStylePage extends StatefulWidget {
  const ClassTableStylePage({super.key});

  @override
  State<ClassTableStylePage> createState() => _ClassTableStylePageState();
}

class _ClassTableStylePageState extends State<ClassTableStylePage> {
  /// The preview, built once and handed the same instance back on every rebuild.
  ///
  /// This is what keeps the page smooth: a tableful of frosted controls costs a blur of the whole
  /// backdrop, and a slider repaints on every frame while it is dragged. Holding the same widget
  /// instance means Flutter does not rebuild it, so the labels still track the finger while the
  /// preview only catches up once it is let go.
  Widget? _preview;

  @override
  void initState() {
    super.initState();
    CurrentTimeIndicatorConfig.loadFromPreference();
    CompletedClassStyleConfig.loadFromPreference();
    GlassStyleConfig.loadFromPreference();
  }

  String _formatPercent(double value) => "${(value * 100).round()}%";

  /// A live change: the sliders and their labels redraw, the preview deliberately does not.
  void _update(VoidCallback update) => setState(update);

  /// A settled change: store it and let the preview rebuild from it.
  void _commit() {
    setState(() => _preview = null);
  }

  Future<void> _saveCurrentTimeSettings() async {
    await CurrentTimeIndicatorConfig.saveToPreference();
    _commit();
  }

  Future<void> _saveClassStyleSettings() async {
    await CompletedClassStyleConfig.saveToPreference();
    _commit();
  }

  Future<void> _saveGlassSettings() async {
    await GlassStyleConfig.saveToPreference();
    _commit();
  }

  Widget _slider({
    required String label,
    required double value,
    required bool enabled,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required VoidCallback onChangeEnd,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: ListTile(
        title: Text(label),
        subtitle: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: enabled ? onChanged : null,
          onChangeEnd: enabled ? (_) => onChangeEnd() : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBrightness = CompletedClassStyleConfig.activeBrightnessFactor;
    final activeBorder = CompletedClassStyleConfig.activeBorderAlpha;
    final activeInner = CompletedClassStyleConfig.activeInnerAlpha;
    final completedSaturation =
        CompletedClassStyleConfig.completedSaturationFactor;
    final completedBrightness =
        CompletedClassStyleConfig.completedBrightnessFactor;
    final completedTextSaturation =
        CompletedClassStyleConfig.completedTextSaturationFactor;
    final completedBorder = CompletedClassStyleConfig.completedBorderAlpha;
    final completedInner = CompletedClassStyleConfig.completedInnerAlpha;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "setting.class_table_style_setting"),
        ),
      ),
      body: ListView(
        children: [
          SectionSettingScaffold(
            title: FlutterI18n.translate(
              context,
              "setting.class_table_style_page.current_time_section",
            ),
            items: [
              SwitchListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.show_current_time_indicator",
                  ),
                ),
                value: CurrentTimeIndicatorConfig.enabled,
                onChanged: (value) {
                  _update(() => CurrentTimeIndicatorConfig.enabled = value);
                  _saveCurrentTimeSettings();
                },
              ),
              SwitchListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.show_current_time_label",
                  ),
                ),
                value: CurrentTimeIndicatorConfig.showTimeLabel,
                onChanged: CurrentTimeIndicatorConfig.enabled
                    ? (value) {
                        _update(
                          () =>
                              CurrentTimeIndicatorConfig.showTimeLabel = value,
                        );
                        _saveCurrentTimeSettings();
                      }
                    : null,
              ),
              SwitchListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.show_today_column_highlight",
                  ),
                ),
                value: CurrentTimeIndicatorConfig.showTodayColumnHighlight,
                onChanged: (value) {
                  _update(
                    () => CurrentTimeIndicatorConfig.showTodayColumnHighlight =
                        value,
                  );
                  _saveCurrentTimeSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionSettingScaffold(
            title: FlutterI18n.translate(
              context,
              "setting.class_table_style_page.active_section",
            ),
            items: [
              _slider(
                enabled: true,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.active_brightness_factor",
                  translationParams: {
                    "value": _formatPercent(activeBrightness),
                  },
                ),
                value: activeBrightness,
                min: 0.5,
                max: 1,
                divisions: 10,
                onChanged: (value) => _update(
                  () =>
                      CompletedClassStyleConfig.activeBrightnessFactor = value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
              _slider(
                enabled: true,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.active_border_alpha",
                  translationParams: {"value": _formatPercent(activeBorder)},
                ),
                value: activeBorder,
                min: 0.1,
                max: 1,
                divisions: 18,
                onChanged: (value) => _update(
                  () => CompletedClassStyleConfig.activeBorderAlpha = value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
              _slider(
                enabled: true,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.active_inner_alpha",
                  translationParams: {"value": _formatPercent(activeInner)},
                ),
                value: activeInner,
                min: 0.1,
                max: 1,
                divisions: 18,
                onChanged: (value) => _update(
                  () => CompletedClassStyleConfig.activeInnerAlpha = value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionSettingScaffold(
            title: FlutterI18n.translate(
              context,
              "setting.class_table_style_page.completed_section",
            ),
            items: [
              SwitchListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.completed_style_enabled",
                  ),
                ),
                value: CompletedClassStyleConfig.completedEnabled,
                onChanged: (value) {
                  _update(
                    () => CompletedClassStyleConfig.completedEnabled = value,
                  );
                  _saveClassStyleSettings();
                },
              ),
              _slider(
                enabled: CompletedClassStyleConfig.completedEnabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.completed_saturation_factor",
                  translationParams: {
                    "value": _formatPercent(completedSaturation),
                  },
                ),
                value: completedSaturation,
                min: 0.1,
                max: 1,
                divisions: 18,
                onChanged: (value) => _update(
                  () => CompletedClassStyleConfig.completedSaturationFactor =
                      value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
              _slider(
                enabled: CompletedClassStyleConfig.completedEnabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.completed_brightness_factor",
                  translationParams: {
                    "value": _formatPercent(completedBrightness),
                  },
                ),
                value: completedBrightness,
                min: 0.5,
                max: 1,
                divisions: 10,
                onChanged: (value) => _update(
                  () => CompletedClassStyleConfig.completedBrightnessFactor =
                      value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
              _slider(
                enabled: CompletedClassStyleConfig.completedEnabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.completed_text_saturation_factor",
                  translationParams: {
                    "value": _formatPercent(completedTextSaturation),
                  },
                ),
                value: completedTextSaturation,
                min: 0.1,
                max: 1,
                divisions: 18,
                onChanged: (value) => _update(
                  () =>
                      CompletedClassStyleConfig.completedTextSaturationFactor =
                          value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
              _slider(
                enabled: CompletedClassStyleConfig.completedEnabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.completed_border_alpha",
                  translationParams: {"value": _formatPercent(completedBorder)},
                ),
                value: completedBorder,
                min: 0.1,
                max: 1,
                divisions: 18,
                onChanged: (value) => _update(
                  () => CompletedClassStyleConfig.completedBorderAlpha = value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
              _slider(
                enabled: CompletedClassStyleConfig.completedEnabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.completed_inner_alpha",
                  translationParams: {"value": _formatPercent(completedInner)},
                ),
                value: completedInner,
                min: 0.1,
                max: 1,
                divisions: 18,
                onChanged: (value) => _update(
                  () => CompletedClassStyleConfig.completedInnerAlpha = value,
                ),
                onChangeEnd: _saveClassStyleSettings,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionSettingScaffold(
            title: FlutterI18n.translate(
              context,
              "setting.class_table_style_page.frosted_section",
            ),
            items: [
              SwitchListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.frosted_enabled",
                  ),
                ),
                subtitle: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.frosted_enabled_hint",
                  ),
                ),
                value: GlassStyleConfig.enabled,
                onChanged: (value) {
                  _update(() => GlassStyleConfig.enabled = value);
                  _saveGlassSettings();
                },
              ),
              _slider(
                enabled: GlassStyleConfig.enabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.frosted_card_sigma",
                  translationParams: {
                    "value": "${GlassStyleConfig.cardSigma.round()}",
                  },
                ),
                value: GlassStyleConfig.cardSigma,
                min: GlassStyleConfig.minSigma,
                max: GlassStyleConfig.maxSigma,
                divisions: 40,
                onChanged: (value) =>
                    _update(() => GlassStyleConfig.cardSigma = value),
                onChangeEnd: _saveGlassSettings,
              ),
              _slider(
                enabled: GlassStyleConfig.enabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.frosted_time_line_sigma",
                  translationParams: {
                    "value": "${GlassStyleConfig.timeLineSigma.round()}",
                  },
                ),
                value: GlassStyleConfig.timeLineSigma,
                min: GlassStyleConfig.minSigma,
                max: GlassStyleConfig.maxSigma,
                divisions: 40,
                onChanged: (value) =>
                    _update(() => GlassStyleConfig.timeLineSigma = value),
                onChangeEnd: _saveGlassSettings,
              ),
              _slider(
                enabled: GlassStyleConfig.enabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.frosted_date_row_sigma",
                  translationParams: {
                    "value": "${GlassStyleConfig.dateRowSigma.round()}",
                  },
                ),
                value: GlassStyleConfig.dateRowSigma,
                min: GlassStyleConfig.minSigma,
                max: GlassStyleConfig.maxSigma,
                divisions: 40,
                onChanged: (value) =>
                    _update(() => GlassStyleConfig.dateRowSigma = value),
                onChangeEnd: _saveGlassSettings,
              ),
              _slider(
                enabled: GlassStyleConfig.enabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.frosted_week_bar_sigma",
                  translationParams: {
                    "value": "${GlassStyleConfig.weekBarSigma.round()}",
                  },
                ),
                value: GlassStyleConfig.weekBarSigma,
                min: GlassStyleConfig.minSigma,
                max: GlassStyleConfig.maxSigma,
                divisions: 40,
                onChanged: (value) =>
                    _update(() => GlassStyleConfig.weekBarSigma = value),
                onChangeEnd: _saveGlassSettings,
              ),
              _slider(
                enabled: GlassStyleConfig.enabled,
                label: FlutterI18n.translate(
                  context,
                  "setting.class_table_style_page.frosted_banner_sigma",
                  translationParams: {
                    "value": "${GlassStyleConfig.bannerSigma.round()}",
                  },
                ),
                value: GlassStyleConfig.bannerSigma,
                min: GlassStyleConfig.minSigma,
                max: GlassStyleConfig.maxSigma,
                divisions: 40,
                onChanged: (value) =>
                    _update(() => GlassStyleConfig.bannerSigma = value),
                onChangeEnd: _saveGlassSettings,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              FlutterI18n.translate(
                context,
                "setting.font_size_page.preview_title",
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _preview ??= const ClassTablePreview(loadStylePreferences: false),
        ],
      ),
    );
  }
}
