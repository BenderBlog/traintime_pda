// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
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
      title: Text(context.t.setting.localizationDialog.title),
      subtitle: Text(selectedLocalization.displayName(context.t)),
      trailing: const Icon(Icons.navigate_next),
      onTap: () async {
        final selected = await showSettingSheet<Localization>(
          context: context,
          builder: (sheetContext) => SettingSheet(
            title: sheetContext.t.setting.localizationDialog.title,
            child: SettingRadioChoices<Localization>(
              value: selectedLocalization,
              options: Localization.values
                  .map(
                    (item) => SettingChoiceOption<Localization>(
                      value: item,
                      label: item.displayName(sheetContext.t),
                    ),
                  )
                  .toList(),
              onChanged: (item) => Navigator.pop(sheetContext, item),
            ),
          ),
        );
        if (selected == null) return;
        await ThemeController.i.setLocale(selected);
        if (!mounted) return;
        setState(() {});
      },
    );
  }
}
