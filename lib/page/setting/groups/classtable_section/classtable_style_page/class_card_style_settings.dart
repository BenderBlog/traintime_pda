// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';
import 'package:watermeter/page/classtable/model/style_config/class_card_style_config.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';

class ClassCardStyleSettings extends StatelessWidget {
  const ClassCardStyleSettings({super.key, required this.onChanged});

  final VoidCallback onChanged;

  String _formatPercent(double value) => "${(value * 100).round()}%";

  void _onActiveBrightnessChanged(double value) {
    ClassCardStyleConfig.activeBrightnessFactor = value;
    onChanged();
  }

  void _onActiveBorderChanged(double value) {
    ClassCardStyleConfig.activeBorderAlpha = value;
    onChanged();
  }

  void _onActiveInnerChanged(double value) {
    ClassCardStyleConfig.activeInnerAlpha = value;
    onChanged();
  }

  Future<void> _saveClassStyleSettings(double _) async {
    await ClassCardStyleConfig.saveToPreference();
  }

  @override
  Widget build(BuildContext context) {
    final activeBrightness = ClassCardStyleConfig.activeBrightnessFactor;
    final activeBorder = ClassCardStyleConfig.activeBorderAlpha;
    final activeInner = ClassCardStyleConfig.activeInnerAlpha;

    return SectionSettingScaffold(
      icon: Icons.play_circle_outline,
      title: context.t.setting.classTableStylePage.activeSection,
      items: SettingSegmentedList(
        items: [
          SettingSliderTile(
            leading: Icons.brightness_6_outlined,
            title: context.t.setting.editor.brightness,
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
            title: context.t.setting.editor.borderOpacity,
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
            title: context.t.setting.editor.fillOpacity,
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
