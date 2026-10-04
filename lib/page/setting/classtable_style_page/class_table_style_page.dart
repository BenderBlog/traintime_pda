// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/setting/classtable_style_page/class_table_background_settings.dart';
import 'package:watermeter/page/setting/classtable_style_page/class_card_style_settings.dart';
import 'package:watermeter/page/setting/classtable_style_page/completed_class_style_settings.dart';
import 'package:watermeter/page/setting/classtable_style_page/current_time_indicator_settings.dart';
import 'package:watermeter/page/classtable/class_table_preview.dart';
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
      body: LayoutBuilder(
        builder: ((context, constraints) {
          bool isVertical = constraints.maxWidth < sheetMaxWidth * 2;
          Widget classPreview = ClassTablePreview(
            loadStylePreferences: false,
            enableVerticalScrolling: true,
            backgroundBlur: _backgroundBlur,
          );
          Widget settingColumn = SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
                  child: Column(
                    children: [
                      ClassTableBackgroundSettings(
                        onChanged: _refreshPreview,
                        onBlurChanged: _updatePreviewBlur,
                      ),
                      CurrentTimeIndicatorSettings(onChanged: _refreshPreview),
                      ClassCardStyleSettings(onChanged: _refreshPreview),
                      CompletedClassStyleSettings(onChanged: _refreshPreview),
                    ],
                  ),
                ),
              ),
            ),
          );

          if (isVertical) {
            return Column(
              children: [
                Expanded(flex: isVertical ? 6 : 5, child: classPreview),
                const Divider(height: 1),
                Expanded(flex: isVertical ? 4 : 5, child: settingColumn),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: classPreview),
              const VerticalDivider(width: 1),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: sheetMaxWidth * 0.8),
                child: settingColumn,
              ),
            ],
          );
        }),
      ),
    );
  }
}
