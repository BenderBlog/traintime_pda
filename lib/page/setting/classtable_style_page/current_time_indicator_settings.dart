// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';

class CurrentTimeIndicatorSettings extends StatelessWidget {
  const CurrentTimeIndicatorSettings({super.key, required this.onChanged});

  final VoidCallback onChanged;

  Future<void> _onIndicatorChanged(bool value) async {
    CurrentTimeIndicatorConfig.enabled = value;
    onChanged();
    await CurrentTimeIndicatorConfig.saveToPreference();
  }

  Future<void> _onTimeLabelChanged(bool value) async {
    CurrentTimeIndicatorConfig.showTimeLabel = value;
    onChanged();
    await CurrentTimeIndicatorConfig.saveToPreference();
  }

  Future<void> _onTodayHighlightChanged(bool value) async {
    CurrentTimeIndicatorConfig.showTodayColumnHighlight = value;
    onChanged();
    await CurrentTimeIndicatorConfig.saveToPreference();
  }

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(
        context,
        "setting.class_table_style_page.current_time_section",
      ),
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.class_table_style_page.show_current_time_indicator",
              ),
            ),
            value: CurrentTimeIndicatorConfig.enabled,
            onChanged: _onIndicatorChanged,
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
                ? _onTimeLabelChanged
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
            onChanged: _onTodayHighlightChanged,
          ),
        ],
      ),
    );
  }
}
