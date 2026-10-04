// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';

class CompletedClassStyleSettings extends StatelessWidget {
  const CompletedClassStyleSettings({super.key, required this.onChanged});

  final VoidCallback onChanged;

  String _formatPercent(double value) => "${(value * 100).round()}%";

  Future<void> _onCompletedStyleEnabledChanged(bool value) async {
    CompletedClassStyleConfig.completedEnabled = value;
    onChanged();
    await CompletedClassStyleConfig.saveToPreference();
  }

  void _onCompletedSaturationChanged(double value) {
    CompletedClassStyleConfig.completedSaturationFactor = value;
    onChanged();
  }

  void _onCompletedBrightnessChanged(double value) {
    CompletedClassStyleConfig.completedBrightnessFactor = value;
    onChanged();
  }

  void _onCompletedTextSaturationChanged(double value) {
    CompletedClassStyleConfig.completedTextSaturationFactor = value;
    onChanged();
  }

  void _onCompletedBorderChanged(double value) {
    CompletedClassStyleConfig.completedBorderAlpha = value;
    onChanged();
  }

  void _onCompletedInnerChanged(double value) {
    CompletedClassStyleConfig.completedInnerAlpha = value;
    onChanged();
  }

  Future<void> _saveClassStyleSettings(double _) async {
    await CompletedClassStyleConfig.saveToPreference();
  }

  @override
  Widget build(BuildContext context) {
    final completedEnabled = CompletedClassStyleConfig.completedEnabled;
    final completedSaturation =
        CompletedClassStyleConfig.completedSaturationFactor;
    final completedBrightness =
        CompletedClassStyleConfig.completedBrightnessFactor;
    final completedTextSaturation =
        CompletedClassStyleConfig.completedTextSaturationFactor;
    final completedBorder = CompletedClassStyleConfig.completedBorderAlpha;
    final completedInner = CompletedClassStyleConfig.completedInnerAlpha;

    return SectionSettingScaffold(
      icon: Icons.check_circle_outline,
      title: context.t.setting.classTableStylePage.completedSection,
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            secondary: const Icon(Icons.check_circle_outline),
            title: Text(
              context.t.setting.classTableStylePage.completedStyleEnabled,
            ),
            value: completedEnabled,
            onChanged: _onCompletedStyleEnabledChanged,
          ),
          SettingSliderTile(
            leading: Icons.palette_outlined,
            title: context.t.setting.editor.fillSaturation,
            formatValue: _formatPercent,
            value: completedSaturation,
            min: 0.1,
            max: 1,
            divisions: 18,
            onChanged: completedEnabled ? _onCompletedSaturationChanged : null,
            onChangeEnd: completedEnabled ? _saveClassStyleSettings : null,
          ),
          SettingSliderTile(
            leading: Icons.brightness_6_outlined,
            title: context.t.setting.editor.brightness,
            formatValue: _formatPercent,
            value: completedBrightness,
            min: 0.5,
            max: 1,
            divisions: 10,
            onChanged: completedEnabled ? _onCompletedBrightnessChanged : null,
            onChangeEnd: completedEnabled ? _saveClassStyleSettings : null,
          ),
          SettingSliderTile(
            leading: Icons.format_color_text,
            title: context.t.setting.editor.textSaturation,
            formatValue: _formatPercent,
            value: completedTextSaturation,
            min: 0.1,
            max: 1,
            divisions: 18,
            onChanged: completedEnabled
                ? _onCompletedTextSaturationChanged
                : null,
            onChangeEnd: completedEnabled ? _saveClassStyleSettings : null,
          ),
          SettingSliderTile(
            leading: Icons.border_outer,
            title: context.t.setting.editor.borderOpacity,
            formatValue: _formatPercent,
            value: completedBorder,
            min: 0.1,
            max: 1,
            divisions: 18,
            onChanged: completedEnabled ? _onCompletedBorderChanged : null,
            onChangeEnd: completedEnabled ? _saveClassStyleSettings : null,
          ),
          SettingSliderTile(
            leading: Icons.opacity,
            title: context.t.setting.editor.fillOpacity,
            formatValue: _formatPercent,
            value: completedInner,
            min: 0.1,
            max: 1,
            divisions: 18,
            onChanged: completedEnabled ? _onCompletedInnerChanged : null,
            onChangeEnd: completedEnabled ? _saveClassStyleSettings : null,
          ),
        ],
      ),
    );
  }
}
