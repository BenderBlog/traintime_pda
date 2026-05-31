// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

part of '../setting_sections.dart';

class SettingAboutSection extends StatelessWidget {
  const SettingAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.about"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
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
            onTap: () => context.pushReplacementNamed(Routes.about),
            trailing: const Icon(Icons.navigate_next),
          ),
          const Divider(),
          ListTile(
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
            onTap: () => _checkUpdate(context),
            trailing: const Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    showToast(
      context: context,
      msg: FlutterI18n.translate(context, "setting.fetching_update"),
    );
    await UpdateNoticeController.i.reloadUpdateNoticeInfo();
    if (!context.mounted) return;
    if (UpdateNoticeController.i.updateMessageStateSignal.value.hasError) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "setting.fetch_failed"),
      );
      return;
    }
    switch (UpdateNoticeController.i.isNewVersionAvaliableComputed.value) {
      case null:
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.current_testing"),
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
          msg: FlutterI18n.translate(context, "setting.current_stable"),
        );
    }
  }
}
