// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Font size / weight setting page with a live class table preview.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/font_setting.dart';

class FontSizePage extends StatefulWidget {
  const FontSizePage({super.key});

  @override
  State<FontSizePage> createState() => _FontSizePageState();
}

class _FontSizePageState extends State<FontSizePage> {
  double get _fontScale => preference.contains(preference.Preference.fontScale)
      ? preference
            .getDouble(preference.Preference.fontScale)
            .clamp(minFontScale, maxFontScale)
            .toDouble()
      : defaultFontScale;

  double get _fontWeight =>
      preference.contains(preference.Preference.fontWeight)
      ? preference
            .getDouble(preference.Preference.fontWeight)
            .clamp(minFontWeight, maxFontWeight)
            .toDouble()
      : defaultFontWeight;

  void _apply() {
    setState(() {
      ThemeController.i.updateTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "setting.font_size_setting")),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ReXCard(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.font_size_page.size_title",
                ),
              ),
              remaining: const [],
              bottomRow: Column(
                children: [
                  Text(
                    "${(_fontScale * 100).round()}%",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Slider(
                    value: _fontScale,
                    min: minFontScale,
                    max: maxFontScale,
                    divisions: 12,
                    onChanged: (value) {
                      preference
                          .setDouble(preference.Preference.fontScale, value)
                          .then((_) => _apply());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ReXCard(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.font_size_page.weight_title",
                ),
              ),
              remaining: const [],
              bottomRow: Column(
                children: [
                  Text(
                    FlutterI18n.translate(
                      context,
                      "setting.font_size_page.weight_${fontWeightLabels[fontWeightLabelIndex(_fontWeight)]}",
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Slider(
                    value: _fontWeight,
                    min: minFontWeight,
                    max: maxFontWeight,
                    divisions: fontWeightSliderDivisions,
                    onChanged: (value) {
                      preference
                          .setDouble(preference.Preference.fontWeight, value)
                          .then((_) => _apply());
                    },
                  ),
                ],
              ),
            ),
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
          const _ClassTablePreview(),
        ],
      ),
    );
  }
}

/// A static (non-interactive) preview of the real second-week class table.
class _ClassTablePreview extends StatelessWidget {
  const _ClassTablePreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: LayoutBuilder(
        builder: (context, constraint) => ClassTableState(
          constraints: constraint,
          controllers: _PreviewClassTableState(),
          child: IgnorePointer(
            child: ClassTableView(index: 1, constraint: constraint),
          ),
        ),
      ),
    );
  }
}

/// A class table state served from the real controller, without live marks.
class _PreviewClassTableState extends ClassTableWidgetState {
  _PreviewClassTableState();

  /// Show the second week directly, ignore the user's week offset.
  @override
  int get offset => 0;

  /// A fixed time in the past, hides the timeline and completion marks.
  @override
  DateTime get currentTime => DateTime(2000, 1, 1);
}
