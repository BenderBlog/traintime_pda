// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/classtable/model/style_config/glass_style_config.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';

/// One slider per frosted surface of the class table.
///
/// The values are written to the preference store when a drag ends rather than on every frame, so
/// holding a finger on a slider does not hammer the disk.
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

  SettingSliderTile _sigmaTile(
    BuildContext context, {
    required IconData leading,
    required String title,
    required double value,
    required ValueChanged<double> onSigmaChanged,
  }) {
    /// Nothing left to blur once the frosted look is off, so the whole row goes disabled.
    final bool enabled = GlassStyleConfig.enabled;

    return SettingSliderTile(
      leading: leading,
      title: title,
      formatValue: (sigma) => sigma.round().toString(),
      value: value,
      min: GlassStyleConfig.minSigma,
      max: GlassStyleConfig.maxSigma,
      divisions: GlassStyleConfig.maxSigma.round(),
      onChanged: enabled ? onSigmaChanged : null,
      onChangeEnd: enabled ? _save : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      icon: Icons.blur_on,
      title: context.t.setting.classTableStylePage.frostedSection,
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            secondary: const Icon(Icons.blur_circular),
            title: Text(context.t.setting.classTableStylePage.frostedEnabled),
            subtitle: Text(
              context.t.setting.classTableStylePage.frostedEnabledHint,
            ),
            value: GlassStyleConfig.enabled,
            onChanged: _onEnabledChanged,
          ),
          _sigmaTile(
            context,
            leading: Icons.square_outlined,
            title: context.t.setting.classTableStylePage.frostedCardSigma,
            value: GlassStyleConfig.cardSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.cardSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            leading: Icons.schedule,
            title: context.t.setting.classTableStylePage.frostedTimeLineSigma,
            value: GlassStyleConfig.timeLineSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.timeLineSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            leading: Icons.calendar_today_outlined,
            title: context.t.setting.classTableStylePage.frostedDateRowSigma,
            value: GlassStyleConfig.dateRowSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.dateRowSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            leading: Icons.view_week_outlined,
            title: context.t.setting.classTableStylePage.frostedWeekBarSigma,
            value: GlassStyleConfig.weekBarSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.weekBarSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            leading: Icons.campaign_outlined,
            title: context.t.setting.classTableStylePage.frostedBannerSigma,
            value: GlassStyleConfig.bannerSigma,
            onSigmaChanged: (value) {
              GlassStyleConfig.bannerSigma = value;
              onChanged();
            },
          ),
          _sigmaTile(
            context,
            leading: Icons.web_asset_outlined,
            title: context.t.setting.classTableStylePage.frostedAppBarSigma,
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
