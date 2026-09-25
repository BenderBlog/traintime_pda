// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutSection extends StatelessWidget {
  final VoidCallback onAboutTap;
  final bool selected;

  const AboutSection({
    super.key,
    required this.onAboutTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      items: [
        ListTile(
          selected: selected,
          selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
          selectedColor: Theme.of(context).colorScheme.onSecondaryContainer,
          leading: const Icon(MingCuteIcons.mgc_information_line),
          title: Text(
            FlutterI18n.translate(context, "setting.about_this_program"),
          ),
          subtitle: Text(
            FlutterI18n.translate(
              context,
              "setting.version",
              translationParams: {
                "version":
                    "${preference.packageInfo.version}+"
                    "${preference.packageInfo.buildNumber}",
              },
            ),
          ),
          onTap: onAboutTap,
          trailing: const Icon(Icons.navigate_next),
        ),
        ListTile(
          leading: const Icon(MingCuteIcons.mgc_download_line),
          title: Text(FlutterI18n.translate(context, "setting.check_update")),
          subtitle: SignalBuilder(
            builder: (context) {
              final updateState =
                  UpdateNoticeController.i.updateMessageStateSignal.value;
              return Text(
                FlutterI18n.translate(
                  context,
                  "setting.latest_version",
                  translationParams: {
                    "latest":
                        updateState.value?.code ??
                        FlutterI18n.translate(context, "setting.waiting"),
                  },
                ),
              );
            },
          ),
          onTap: () {
            showToast(
              context: context,
              msg: FlutterI18n.translate(context, "setting.fetching_update"),
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
                    msg: FlutterI18n.translate(context, "setting.fetch_failed"),
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
                      msg: FlutterI18n.translate(
                        context,

                        "setting.current_testing",
                      ),
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
                      msg: FlutterI18n.translate(
                        context,
                        "setting.current_stable",
                      ),
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
