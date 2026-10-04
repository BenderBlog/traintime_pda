// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';

class ClassCardStyleSettings extends StatelessWidget {
  const ClassCardStyleSettings({super.key, required this.onChanged});

  final VoidCallback onChanged;

  String _formatPercent(double value) => "${(value * 100).round()}%";

  void _onActiveBrightnessChanged(double value) {
    CompletedClassStyleConfig.activeBrightnessFactor = value;
    onChanged();
  }

  void _onActiveBorderChanged(double value) {
    CompletedClassStyleConfig.activeBorderAlpha = value;
    onChanged();
  }

  void _onActiveInnerChanged(double value) {
    CompletedClassStyleConfig.activeInnerAlpha = value;
    onChanged();
  }

  Future<void> _saveClassStyleSettings(double _) async {
    await CompletedClassStyleConfig.saveToPreference();
  }

  @override
  Widget build(BuildContext context) {
    final activeBrightness = CompletedClassStyleConfig.activeBrightnessFactor;
    final activeBorder = CompletedClassStyleConfig.activeBorderAlpha;
    final activeInner = CompletedClassStyleConfig.activeInnerAlpha;

    return SectionSettingScaffold(
      icon: Icons.play_circle_outline,
      title: FlutterI18n.translate(
        context,
        "setting.class_table_style_page.active_section",
      ),
      items: SettingSegmentedList(
        items: [
          SettingSliderTile(
            leading: Icons.brightness_6_outlined,
            title: FlutterI18n.translate(context, 'setting.editor.brightness'),
            formatValue: _formatPercent,
            value: activeBrightness,
            min: 0.5,
            max: 1,
            divisions: 10,
            onChanged: _onActiveBrightnessChanged,
            onChangeEnd: _saveClassStyleSettings,
          ),
          SettingSliderTile(
            leading: Icons.border_outer,
            title: FlutterI18n.translate(
              context,
              'setting.editor.border_opacity',
            ),
            formatValue: _formatPercent,
            value: activeBorder,
            min: 0.1,
            max: 1,
            divisions: 18,
            onChanged: _onActiveBorderChanged,
            onChangeEnd: _saveClassStyleSettings,
          ),
          SettingSliderTile(
            leading: Icons.opacity,
            title: FlutterI18n.translate(
              context,
              'setting.editor.fill_opacity',
            ),
            formatValue: _formatPercent,
            value: activeInner,
            min: 0.1,
            max: 1,
            divisions: 18,
            onChanged: _onActiveInnerChanged,
            onChangeEnd: _saveClassStyleSettings,
          ),
        ],
      ),
    );
  }
}
