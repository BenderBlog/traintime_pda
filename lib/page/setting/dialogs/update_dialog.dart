// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/message/message.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateMessage updateMessage;
  const UpdateDialog({
    super.key,
    required this.updateMessage,
  });

  @override
  Widget build(BuildContext context) {
    String text = FlutterI18n.translate(
      context,
      "setting.update_dialog.new_content",
      translationParams: {
        "code": updateMessage.code,
      },
    );
    for (int i = 0; i < updateMessage.update.length; ++i) {
      text += "${i + 1}.${updateMessage.update[i]}\n";
    }
    return AlertDialog(
      title: Text(FlutterI18n.translate(
        context,
        "setting.update_dialog.new_version",
      )),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(FlutterI18n.translate(
            context,
            "setting.update_dialog.not_now",
          )),
        ),
        if (Platform.isIOS)
          TextButton(
            onPressed: () => launchUrlString(updateMessage.ioslink),
            child: Text(FlutterI18n.translate(
              context,
              "setting.update_dialog.app_store",
            )),
          )
        else if (Platform.isAndroid)
          TextButton(
            onPressed: () => launchUrlString(updateMessage.fdroid),
            child: Text(FlutterI18n.translate(
              context,
              "setting.update_dialog.download_apk",
            )),
          )
        else
          TextButton(
            onPressed: () => launchUrlString(updateMessage.github),
            child: Text(FlutterI18n.translate(
              context,
              "setting.update_dialog.github_release",
            )),
          )
      ],
    );
  }
}
