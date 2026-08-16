// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/generated/translations.g.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: context.t.setting.about,
      items: [
        ListTile(
          title: Text(context.t.setting.aboutThisProgram),
          subtitle: Text(
            context.t.setting.version(
              version:
                  "${preference.packageInfo.version}+"
                  "${preference.packageInfo.buildNumber}",
            ),
          ),
          onTap: () => context.pushReplacementNamed(Routes.about),
          trailing: const Icon(Icons.navigate_next),
        ),
        ListTile(
          title: Text(context.t.setting.checkUpdate),
          subtitle: SignalBuilder(
            builder: (context) {
              final updateState =
                  UpdateNoticeController.i.updateMessageStateSignal.value;
              return Text(
                context.t.setting.latestVersion(
                  latest: updateState.value?.code ?? context.t.setting.waiting,
                ),
              );
            },
          ),
          onTap: () {
            showToast(
              context: context,
              msg: context.t.setting.fetchingUpdate,
            );
            UpdateNoticeController.i.reloadUpdateNoticeInfo().then((
              value,
            ) async {
              if (context.mounted) {
                if (UpdateNoticeController
                    .i
                    .updateMessageStateSignal
                    .value
                    .hasError) {
                  showToast(
                    context: context,
                    msg: context.t.setting.fetchFailed,
                  );
                  return;
                }
                switch (UpdateNoticeController
                    .i
                    .isNewVersionAvaliableComputed
                    .value) {
                  case null:
                    showToast(
                      context: context,
                      msg: context.t.setting.currentTesting,
                    );
                  case true:
                    await showDialog(
                      context: context,
                      builder: (context) => SignalBuilder(
                        builder: (context) => UpdateDialog(
                          updateMessage: UpdateNoticeController
                              .i
                              .updateMessageStateSignal
                              .value
                              .value!,
                        ),
                      ),
                    );
                  case false:
                    showToast(
                      context: context,
                      msg: context.t.setting.currentStable,
                    );
                }
              }
            });
          },
          trailing: const Icon(Icons.navigate_next),
        ),
      ],
    );
  }
}
