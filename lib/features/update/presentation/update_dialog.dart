// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../domain/update_release.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key, required this.release});

  final UpdateRelease release;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final (url, label) = switch (platform) {
      TargetPlatform.iOS => (
        release.iosUrl,
        context.t.settings.updateDialog.appStore,
      ),
      TargetPlatform.android => (
        release.androidUrl,
        context.t.settings.updateDialog.downloadApk,
      ),
      _ => (release.githubUrl, context.t.settings.updateDialog.githubRelease),
    };
    final changes = [
      context.t.settings.updateDialog.newContent(code: release.code),
      for (var i = 0; i < release.changes.length; i++)
        '${i + 1}.${release.changes[i]}',
    ].join('\n');
    return AlertDialog(
      title: Text(context.t.settings.updateDialog.newVersion),
      content: Text(changes),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.settings.updateDialog.notNow),
        ),
        TextButton(onPressed: () => launchUrlString(url), child: Text(label)),
      ],
    );
  }
}
