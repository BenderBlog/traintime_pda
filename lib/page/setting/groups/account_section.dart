// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(context, "setting.account_setting"),
      items: [
        if (!preference.getBool(preference.Preference.role)) ...[
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.sport_password_setting"),
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
        // const Divider(),
        // ListTile(
        //   title: Text(
        //     FlutterI18n.translate(context, "setting.aircon_imei_title"),
        //   ),
        //   subtitle: Text(
        //     preference
        //             .getString(preference.Preference.airconImei)
        //             .isEmpty
        //         ? FlutterI18n.translate(
        //             context,
        //             "setting.aircon_imei_not_set",
        //           )
        //         : FlutterI18n.translate(
        //             context,
        //             "setting.aircon_imei_current",
        //             translationParams: {
        //               "imei": preference.getString(
        //                 preference.Preference.airconImei,
        //               ),
        //             },
        //           ),
        //   ),
        //   trailing: const Icon(Icons.qr_code_scanner),
        //   onTap: () {
        //     showDialog(
        //       context: context,
        //       builder: (context) => const AirconImeiDialog(),
        //     ).then((_) {
        //       if (mounted) setState(() {});
        //     });
        //   },
        // ),
      ],
    );
  }
}
