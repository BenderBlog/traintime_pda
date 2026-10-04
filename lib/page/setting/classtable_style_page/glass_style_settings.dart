// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';

/// One slider per blurred surface of the class table.
///
/// The values are written to the preference store when a drag ends rather than
/// on every frame, so holding a finger on the slider does not hammer the disk.
class GlassStyleSettings extends StatelessWidget {
  const GlassStyleSettings({super.key, required this.onChanged});

  /// Called on each change so the surrounding preview follows the finger.
  final VoidCallback onChanged;

  Future<void> _onEnabledChanged(bool value) async {
    GlassStyleConfig.enabled = value;
    onChanged();
    await GlassStyleConfig.saveToPreference();
  }

  Future<void> _save(double _) async {
    await GlassStyleConfig.saveToPreference();
  }

  Widget _sigmaTile(
    BuildContext context, {
    required String titleKey,
    required double value,
    required ValueChanged<double> onSigmaChanged,
  }) {
    return ListTile(
      title: Text(
        FlutterI18n.translate(
          context,
          titleKey,
          translationParams: {"value": "${value.round()}"},
        ),
      ),
      subtitle: SizedBox(
        height: 48,
        child: Transform.translate(
          offset: const Offset(-10, 0),
          child: M3ESlider(
            value: value,
            min: GlassStyleConfig.minSigma,
            max: GlassStyleConfig.maxSigma,
            divisions: GlassStyleConfig.maxSigma.round(),
            // Nothing to blur while the frosted look is switched off.
            onChanged: GlassStyleConfig.enabled ? onSigmaChanged : null,
            onChangeEnd: _save,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(
        context,
        "setting.class_table_style_page.frosted_section",
      ),
      items: SettingSegmentedList(
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
            onChanged: _onEnabledChanged,
          ),
          _sigmaTile(
            context,
            titleKey: "setting.class_table_style_page.frosted_card_sigma",
            value: GlassStyleConfig.cardSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.cardSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            titleKey: "setting.class_table_style_page.frosted_time_line_sigma",
            value: GlassStyleConfig.timeLineSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.timeLineSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            titleKey: "setting.class_table_style_page.frosted_date_row_sigma",
            value: GlassStyleConfig.dateRowSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.dateRowSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            titleKey: "setting.class_table_style_page.frosted_week_bar_sigma",
            value: GlassStyleConfig.weekBarSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.weekBarSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            titleKey: "setting.class_table_style_page.frosted_banner_sigma",
            value: GlassStyleConfig.bannerSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.bannerSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            titleKey: "setting.class_table_style_page.frosted_app_bar_sigma",
            value: GlassStyleConfig.appBarSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.appBarSigma = value;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
