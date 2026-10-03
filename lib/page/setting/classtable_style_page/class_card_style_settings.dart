// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/classtable_style_page/completed_class_style_settings.dart';

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

    return Column(
      children: [
        SectionSettingScaffold(
          title: FlutterI18n.translate(
            context,
            "setting.class_table_style_page.active_section",
          ),
          items: SettingSegmentedList(
            items: [
              ListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.active_brightness_factor",
                    translationParams: {
                      "value": _formatPercent(activeBrightness),
                    },
                  ),
                ),
                subtitle: SizedBox(
                  height: 48,
                  child: Transform.translate(
                    offset: const Offset(-10, 0),
                    child: M3ESlider(
                      value: activeBrightness,
                      min: 0.5,
                      max: 1,
                      divisions: 10,
                      onChanged: _onActiveBrightnessChanged,
                      onChangeEnd: _saveClassStyleSettings,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.active_border_alpha",
                    translationParams: {"value": _formatPercent(activeBorder)},
                  ),
                ),
                subtitle: SizedBox(
                  height: 48,
                  child: Transform.translate(
                    offset: const Offset(-10, 0),
                    child: M3ESlider(
                      value: activeBorder,
                      min: 0.1,
                      max: 1,
                      divisions: 18,
                      onChanged: _onActiveBorderChanged,
                      onChangeEnd: _saveClassStyleSettings,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_page.active_inner_alpha",
                    translationParams: {"value": _formatPercent(activeInner)},
                  ),
                ),
                subtitle: SizedBox(
                  height: 48,
                  child: Transform.translate(
                    offset: const Offset(-10, 0),
                    child: M3ESlider(
                      value: activeInner,
                      min: 0.1,
                      max: 1,
                      divisions: 18,
                      onChanged: _onActiveInnerChanged,
                      onChangeEnd: _saveClassStyleSettings,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CompletedClassStyleSettings(onChanged: onChanged),
      ],
    );
  }
}
