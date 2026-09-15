// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/setting/class_table_preview.dart';

class ClassTableStylePage extends StatefulWidget {
  const ClassTableStylePage({super.key});

  @override
  State<ClassTableStylePage> createState() => _ClassTableStylePageState();
}

class _ClassTableStylePageState extends State<ClassTableStylePage> {
  int _previewVersion = 0;

  @override
  void initState() {
    super.initState();
    CurrentTimeIndicatorConfig.loadFromPreference();
    CompletedClassStyleConfig.loadFromPreference();
  }

  String _formatPercent(double value) => "${(value * 100).round()}%";

  void _update(VoidCallback update) {
    setState(() {
      update();
      _previewVersion++;
    });
  }

  Future<void> _saveCurrentTimeSettings() async {
    await CurrentTimeIndicatorConfig.saveToPreference();
  }

  Future<void> _saveClassStyleSettings() async {
    await CompletedClassStyleConfig.saveToPreference();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: enabled ? (_) => onChangeEnd() : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String translation(String key, [Map<String, String>? params]) =>
        FlutterI18n.translate(context, key, translationParams: params);
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

    Widget sectionCard(String title, List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ListTile(contentPadding: EdgeInsets.zero, title: Text(title)),
            ...children,
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(translation("setting.class_table_style_setting")),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          sectionCard(
            translation("setting.class_table_style_page.current_time_section"),
            [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  translation(
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
                contentPadding: EdgeInsets.zero,
                title: Text(
                  translation(
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
                contentPadding: EdgeInsets.zero,
                title: Text(
                  translation(
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
          sectionCard(
            translation("setting.class_table_style_page.active_section"),
            [
              _slider(
                enabled: true,
                label: translation(
                      "setting.class_table_style_page.active_brightness_factor",
                  {"value": _formatPercent(activeBrightness)},
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
                label: translation(
                      "setting.class_table_style_page.active_border_alpha",
                  {"value": _formatPercent(activeBorder)},
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
                label: translation(
                      "setting.class_table_style_page.active_inner_alpha",
                  {"value": _formatPercent(activeInner)},
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
          sectionCard(
            translation("setting.class_table_style_page.completed_section"),
            [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  translation(
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
                label: translation(
                    "setting.class_table_style_page.completed_saturation_factor",
                  {"value": _formatPercent(completedSaturation)},
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
                label: translation(
                    "setting.class_table_style_page.completed_brightness_factor",
                  {"value": _formatPercent(completedBrightness)},
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
                label: translation(
                    "setting.class_table_style_page.completed_text_saturation_factor",
                  {"value": _formatPercent(completedTextSaturation)},
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
                label: translation(
                    "setting.class_table_style_page.completed_border_alpha",
                  {"value": _formatPercent(completedBorder)},
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
                label: translation(
                    "setting.class_table_style_page.completed_inner_alpha",
                  {"value": _formatPercent(completedInner)},
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
          ClassTablePreview(
            key: ValueKey(_previewVersion),
            loadStylePreferences: false,
          ),
        ],
      ),
    );
  }
}
