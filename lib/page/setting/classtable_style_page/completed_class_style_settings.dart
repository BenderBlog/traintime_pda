// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:m3e_core/m3e_core.dart';
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
      title: FlutterI18n.translate(
        context,
        "setting.class_table_style_page.completed_section",
      ),
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.class_table_style_page.completed_style_enabled",
              ),
            ),
            value: completedEnabled,
            onChanged: _onCompletedStyleEnabledChanged,
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.class_table_style_page.completed_saturation_factor",
                translationParams: {
                  "value": _formatPercent(completedSaturation),
                },
              ),
            ),
            subtitle: SizedBox(
              height: 48,
              child: Transform.translate(
                offset: const Offset(-10, 0),
                child: M3ESlider(
                  value: completedSaturation,
                  min: 0.1,
                  max: 1,
                  divisions: 18,
                  onChanged: completedEnabled
                      ? _onCompletedSaturationChanged
                      : null,
                  onChangeEnd: completedEnabled
                      ? _saveClassStyleSettings
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.class_table_style_page.completed_brightness_factor",
                translationParams: {
                  "value": _formatPercent(completedBrightness),
                },
              ),
            ),
            subtitle: SizedBox(
              height: 48,
              child: Transform.translate(
                offset: const Offset(-10, 0),
                child: M3ESlider(
                  value: completedBrightness,
                  min: 0.5,
                  max: 1,
                  divisions: 10,
                  onChanged: completedEnabled
                      ? _onCompletedBrightnessChanged
                      : null,
                  onChangeEnd: completedEnabled
                      ? _saveClassStyleSettings
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.class_table_style_page.completed_text_saturation_factor",
                translationParams: {
                  "value": _formatPercent(completedTextSaturation),
                },
              ),
            ),
            subtitle: SizedBox(
              height: 48,
              child: Transform.translate(
                offset: const Offset(-10, 0),
                child: M3ESlider(
                  value: completedTextSaturation,
                  min: 0.1,
                  max: 1,
                  divisions: 18,
                  onChanged: completedEnabled
                      ? _onCompletedTextSaturationChanged
                      : null,
                  onChangeEnd: completedEnabled
                      ? _saveClassStyleSettings
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.class_table_style_page.completed_border_alpha",
                translationParams: {"value": _formatPercent(completedBorder)},
              ),
            ),
            subtitle: SizedBox(
              height: 48,
              child: Transform.translate(
                offset: const Offset(-10, 0),
                child: M3ESlider(
                  value: completedBorder,
                  min: 0.1,
                  max: 1,
                  divisions: 18,
                  onChanged: completedEnabled
                      ? _onCompletedBorderChanged
                      : null,
                  onChangeEnd: completedEnabled
                      ? _saveClassStyleSettings
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.class_table_style_page.completed_inner_alpha",
                translationParams: {"value": _formatPercent(completedInner)},
              ),
            ),
            subtitle: SizedBox(
              height: 48,
              child: Transform.translate(
                offset: const Offset(-10, 0),
                child: M3ESlider(
                  value: completedInner,
                  min: 0.1,
                  max: 1,
                  divisions: 18,
                  onChanged: completedEnabled ? _onCompletedInnerChanged : null,
                  onChangeEnd: completedEnabled
                      ? _saveClassStyleSettings
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
