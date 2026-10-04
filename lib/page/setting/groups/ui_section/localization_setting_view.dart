// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/setting/setting_dropdown_button.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class LocalizationSettingView extends StatefulWidget {
  const LocalizationSettingView({super.key});

  @override
  State<LocalizationSettingView> createState() =>
      _LocalizationSettingViewState();
}

class _LocalizationSettingViewState extends State<LocalizationSettingView> {
  @override
  Widget build(BuildContext context) {
    final selectedLocalization = Localization.values.firstWhere(
      (item) =>
          item.string ==
          preference.getString(preference.Preference.localization),
    );

    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(
        FlutterI18n.translate(context, "setting.localization_dialog.title"),
      ),
      trailing: SizedBox(
        width: 180,
        child: SettingDropdownButton<Localization>(
          value: selectedLocalization,
          items: Localization.values.map((item) {
            return DropdownMenuItem<Localization>(
              value: item,
              child: Text(FlutterI18n.translate(context, item.toShow)),
            );
          }).toList(),
          onChanged: (item) async {
            if (item == null) return;
            await preference.setString(
              preference.Preference.localization,
              item.string,
            );
            if (!mounted) return;
            ThemeController.i.updateTheme();
            setState(() {});
          },
        ),
      ),
    );
  }
}
