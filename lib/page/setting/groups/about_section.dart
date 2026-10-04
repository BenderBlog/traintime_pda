// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/routing/routes.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      //title: context.t.setting.aboutInfo,
      //icon: Icons.info,
      items: SettingSegmentedList(
        items: [
          ListTile(
            leading: const Icon(MingCuteIcons.mgc_information_line),
            title: Text(context.t.setting.aboutThisProgram),
            subtitle: Text(
              context.t.setting.version(
                version:
                    "${preference.packageInfo.version}+"
                    "${preference.packageInfo.buildNumber}",
              ),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.pushReplacementNamed(Routes.about),
          ),
          ListTile(
            leading: const Icon(MingCuteIcons.mgc_download_line),
            title: Text(context.t.setting.checkUpdate),
            subtitle: SignalBuilder(
              builder: (context) {
                final updateState =
                    UpdateNoticeController.i.updateMessageStateSignal.value;
                return Text(
                  context.t.setting.latestVersion(
                    latest:
                        updateState.value?.code ?? context.t.setting.waiting,
                  ),
                );
              },
            ),
            trailing: const Icon(Icons.navigate_next),
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
          ),
        ],
      ),
    );
  }
}
