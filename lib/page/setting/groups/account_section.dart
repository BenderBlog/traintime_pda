// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/aircon_imei_page.dart';
import 'package:watermeter/page/setting/password_setting_sheet.dart';
import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AccountSection extends StatefulWidget {
  const AccountSection({super.key});

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  String _passwordStatus(preference.Preference key) => context.t.resolveKey(
    preference.getString(key).isEmpty
        ? 'setting.editor.password_not_set'
        : 'setting.editor.password_set',
  );

  Future<void> _editPassword(preference.Preference key, String titleKey) async {
    final saved = await showPasswordSettingSheet(
      context: context,
      preferenceKey: key,
      titleKey: titleKey,
    );
    if (saved == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionSettingScaffold(
          title: context.t.setting.generalAccountSettings,
          items: SettingSegmentedList(
            items: [
              ListTile(
                leading: const Icon(MingCuteIcons.mgc_wifi_line),
                title: Text(context.t.setting.schoolnetPasswordSetting),
                subtitle: Text(
                  '${_passwordStatus(preference.Preference.schoolNetQueryPassword)} · ${context.t.setting.schoolnetPasswordDescription}',
                ),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  _editPassword(
                    preference.Preference.schoolNetQueryPassword,
                    'setting.change_schoolnet_password_title',
                  );
                },
              ),
              ListTile(
                title: Text(context.t.setting.airconImeiTitle),
                subtitle: SignalBuilder(
                  builder: (context) {
                    final imei = AirconController.i.imeiSignal.value;
                    return Text(
                      imei.isEmpty
                          ? context.t.setting.airconImeiNotSet
                          : context.t.setting.airconImeiCurrent(imei: imei),
                    );
                  },
                ),
                leading: const Icon(Icons.ac_unit),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  context.push<void>(const AirconImeiPage());
                },
              ),
            ],
          ),
        ),
        if (!preference.getBool(preference.Preference.role))
          SectionSettingScaffold(
            title: context.t.setting.undergraduateSystemAccounts,
            items: SettingSegmentedList(
              items: [
                ListTile(
                  leading: const Icon(MingCuteIcons.mgc_run_line),
                  title: Text(context.t.setting.sportPasswordSetting),
                  subtitle: Text(
                    _passwordStatus(preference.Preference.sportPassword),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    _editPassword(
                      preference.Preference.sportPassword,
                      'setting.change_sport_title',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(MingCuteIcons.mgc_flask_line),
                  title: Text(context.t.setting.experimentPasswordSetting),
                  subtitle: Text(
                    _passwordStatus(preference.Preference.experimentPassword),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    _editPassword(
                      preference.Preference.experimentPassword,
                      'setting.change_experiment_title',
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
