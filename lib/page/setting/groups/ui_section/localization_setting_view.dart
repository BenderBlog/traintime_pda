// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/setting/setting_choice_control.dart';
import 'package:watermeter/page/public_widget/setting/setting_edit_sheet.dart';
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
      orElse: () => Localization.undefined,
    );

    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(
        FlutterI18n.translate(context, "setting.localization_dialog.title"),
      ),
      subtitle: Text(
        FlutterI18n.translate(context, selectedLocalization.toShow),
      ),
      trailing: const Icon(Icons.navigate_next),
      onTap: () async {
        final selected = await showSettingSheet<Localization>(
          context: context,
          builder: (sheetContext) => SettingSheet(
            title: FlutterI18n.translate(
              sheetContext,
              'setting.localization_dialog.title',
            ),
            child: SettingRadioChoices<Localization>(
              value: selectedLocalization,
              options: Localization.values
                  .map(
                    (item) => SettingChoiceOption<Localization>(
                      value: item,
                      label: FlutterI18n.translate(sheetContext, item.toShow),
                    ),
                  )
                  .toList(),
              onChanged: (item) => Navigator.pop(sheetContext, item),
            ),
          ),
        );
        if (selected == null) return;
        await preference.setString(
          preference.Preference.localization,
          selected.string,
        );
        if (!mounted) return;
        ThemeController.i.updateTheme();
        setState(() {});
      },
    );
  }
}
