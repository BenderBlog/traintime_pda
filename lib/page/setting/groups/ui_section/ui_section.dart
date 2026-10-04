// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/groups/ui_section/brightness_setting_view.dart';
import 'package:watermeter/page/setting/groups/ui_section/color_setting_view.dart';
import 'package:watermeter/page/setting/groups/ui_section/font_size_setting_view.dart';
import 'package:watermeter/page/setting/groups/ui_section/font_weight_setting_view.dart';
import 'package:watermeter/page/setting/groups/ui_section/localization_setting_view.dart';
import 'package:watermeter/page/setting/groups/ui_section/low_electricity_threshold_setting_view.dart';
import 'package:watermeter/page/setting/groups/ui_section/low_electricity_warning_setting_view.dart';
import 'package:watermeter/page/setting/groups/ui_section/simplify_timeline_setting_view.dart';

class UiSection extends StatelessWidget {
  const UiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionSettingScaffold(
          icon: Icons.color_lens,
          title: context.t.setting.sections.display,
          items: SettingSegmentedList(
            items: const [ColorSettingView(), BrightnessSettingView()],
          ),
        ),
        SectionSettingScaffold(
          icon: Icons.translate,
          title: context.t.setting.sections.languageAndText,
          items: SettingSegmentedList(
            items: const [
              LocalizationSettingView(),
              FontSizeSettingView(),
              FontWeightSettingView(),
            ],
          ),
        ),
        SectionSettingScaffold(
          icon: Icons.home,
          title: context.t.setting.sections.home,
          items: const SettingSegmentedList(
            items: [
              SimplifyTimelineSettingView(),
              LowElectricityWarningSettingView(),
              LowElectricityThresholdSettingView(),
            ],
          ),
        ),
      ],
    );
  }
}
