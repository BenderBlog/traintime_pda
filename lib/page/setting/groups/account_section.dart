// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/setting/dialogs/aircon_imei_dialog.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      items: SettingSegmentedList(
        items: [
          if (!preference.getBool(preference.Preference.role)) ...[
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_run_line),
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.sport_password_setting",
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const SportPasswordDialog(),
                );
              },
            ),
            ListTile(
              leading: const Icon(MingCuteIcons.mgc_flask_line),
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.experiment_password_setting",
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const ExperimentPasswordDialog(),
                );
              },
            ),
          ],

          ListTile(
            leading: const Icon(MingCuteIcons.mgc_wifi_line),
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.schoolnet_password_setting",
              ),
            ),
            subtitle: Text(
              FlutterI18n.translate(
                context,
                "setting.schoolnet_password_description",
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const SchoolNetPasswordDialog(),
              );
            },
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.aircon_imei_title"),
            ),
            subtitle: SignalBuilder(
              builder: (context) {
                final imei = AirconController.i.imeiSignal.value;
                return Text(
                  imei.isEmpty
                      ? FlutterI18n.translate(
                          context,
                          "setting.aircon_imei_not_set",
                        )
                      : FlutterI18n.translate(
                          context,
                          "setting.aircon_imei_current",
                          translationParams: {"imei": imei},
                        ),
                );
              },
            ),
            trailing: const Icon(Icons.qr_code_scanner),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => const AirconImeiDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}
