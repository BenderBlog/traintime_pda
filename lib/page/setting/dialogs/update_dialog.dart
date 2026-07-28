// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/pda_service/message.dart';
import 'package:watermeter/generated/translations.g.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateMessage updateMessage;
  const UpdateDialog({super.key, required this.updateMessage});

  @override
  Widget build(BuildContext context) {
    String text = context.t.setting.updateDialog.newContent(code: updateMessage.code);
    for (int i = 0; i < updateMessage.update.length; ++i) {
      text += "${i + 1}.${updateMessage.update[i]}\n";
    }
    return AlertDialog(
      title: Text(
        context.t.setting.updateDialog.newVersion,
      ),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            context.t.setting.updateDialog.notNow,
          ),
        ),
        if (Platform.isIOS)
          TextButton(
            onPressed: () => launchUrlString(updateMessage.ioslink),
            child: Text(
              context.t.setting.updateDialog.appStore,
            ),
          )
        else if (Platform.isAndroid)
          TextButton(
            onPressed: () => launchUrlString(updateMessage.fdroid),
            child: Text(
              context.t.setting.updateDialog.downloadApk,
            ),
          )
        else
          TextButton(
            onPressed: () => launchUrlString(updateMessage.github),
            child: Text(
              context.t.setting.updateDialog.githubRelease,
            ),
          ),
      ],
    );
  }
}
