// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

part of '../setting_sections.dart';

class SettingCoreSection extends StatelessWidget {
  final SettingActionsController actions;

  const SettingCoreSection({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: buildSettingSectionTitle(
        FlutterI18n.translate(context, "setting.core_setting"),
      ),
      remaining: const [],
      bottomRow: Column(
        children: [
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.check_logger")),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.push(TalkerScreen(talker: log)),
          ),
          const Divider(),
          if (Platform.isAndroid || Platform.isIOS) ...[
            ListTile(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.notification_debug_page",
                ),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () => context.push(NotificationDebugPage()),
            ),
            const Divider(),
          ],
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "setting.clear_and_restart"),
            ),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmClearAndRestart(context),
          ),
          const Divider(),
          ListTile(
            title: Text(FlutterI18n.translate(context, "setting.logout")),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAndRestart(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(
            context,
            "setting.clear_and_restart_dialog.title",
          ),
        ),
        content: Text(
          FlutterI18n.translate(
            context,
            "setting.clear_and_restart_dialog.content",
          ),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () async {
              final pd = ProgressDialog(context: context);
              pd.show(
                msg: FlutterI18n.translate(
                  context,
                  "setting.clear_and_restart_dialog.cleaning",
                ),
              );
              await actions.clearAppCache();
              if (!context.mounted) return;
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "setting.clear_and_restart_dialog.clear",
                ),
              );
              _restartApp(
                context,
                iosTitleKey: "restart_app.title_cache_cleared",
              );
            },
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, "setting.logout_dialog.title"),
        ),
        content: Text(
          FlutterI18n.translate(context, "setting.logout_dialog.content"),
        ),
        actions: [
          _CancelButton(),
          TextButton(
            onPressed: () async {
              final pd = ProgressDialog(context: context);
              pd.show(
                msg: FlutterI18n.translate(
                  context,
                  "setting.logout_dialog.logging_out",
                ),
              );
              await actions.logoutAndClearLocalState();
              if (!context.mounted) return;
              pd.close();
              _restartApp(context, iosTitleKey: "restart_app.title_logged_out");
            },
            child: Text(FlutterI18n.translate(context, "confirm")),
          ),
        ],
      ),
    );
  }

  void _restartApp(BuildContext context, {required String iosTitleKey}) {
    if (Platform.isIOS) {
      Restart.restartApp(
        mode: RestartMode.notificationFallback,
        notificationTitle: FlutterI18n.translate(context, iosTitleKey),
        notificationBody: FlutterI18n.translate(context, "restart_app.content"),
      );
    } else {
      Restart.restartApp();
    }
  }
}
