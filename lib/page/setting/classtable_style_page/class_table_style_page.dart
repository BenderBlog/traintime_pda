// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/setting/classtable_style_page/class_table_background_settings.dart';
import 'package:watermeter/page/setting/classtable_style_page/class_card_style_settings.dart';
import 'package:watermeter/page/setting/classtable_style_page/current_time_indicator_settings.dart';
import 'package:watermeter/page/setting/classtable_style_page/glass_style_settings.dart';
import 'package:watermeter/page/setting/class_table_preview.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ClassTableStylePage extends StatefulWidget {
  const ClassTableStylePage({super.key});

  @override
  State<ClassTableStylePage> createState() => _ClassTableStylePageState();
}

class _ClassTableStylePageState extends State<ClassTableStylePage> {
  double _backgroundBlur = preference.getDouble(
    preference.Preference.classTableBackgroundBlur,
  );

  @override
  void initState() {
    super.initState();
    CurrentTimeIndicatorConfig.loadFromPreference();
    CompletedClassStyleConfig.loadFromPreference();
    GlassStyleConfig.loadFromPreference();
  }

  void _rebuild() {}

  void _refreshPreview() {
    setState(_rebuild);
  }

  void _updatePreviewBlur(double value) {
    _backgroundBlur = value;
    setState(_rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "setting.class_table_style_setting"),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.font_size_page.preview_title",
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ClassTablePreview(
                    loadStylePreferences: false,
                    enableVerticalScrolling: true,
                    backgroundBlur: _backgroundBlur,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const ClampingScrollPhysics(),
              children: [
                ClassTableBackgroundSettings(
                  onChanged: _refreshPreview,
                  onBlurChanged: _updatePreviewBlur,
                ),
                const SizedBox(height: 16),
                GlassStyleSettings(onChanged: _refreshPreview),
                const SizedBox(height: 16),
                CurrentTimeIndicatorSettings(onChanged: _refreshPreview),
                ClassCardStyleSettings(onChanged: _refreshPreview),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
