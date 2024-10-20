// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
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
    String text = "版本号 ${updateMessage.code} 新增内容：\n";
    for (int i = 0; i < updateMessage.update.length; ++i) {
      text += "${i + 1}.${updateMessage.update[i]}\n";
    }
    return AlertDialog(
      title: const Text("新版本发布"),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("暂不更新"),
        ),
        if (Platform.isIOS)
          TextButton(
            onPressed: () => launchUrlString(updateMessage.ioslink),
            child: const Text("App Store 更新"),
          )
        else if (Platform.isAndroid)
          TextButton(
            onPressed: () => launchUrlString(updateMessage.fdroid),
            child: const Text("下载安装包"),
          )
        else
          TextButton(
            onPressed: () => launchUrlString(updateMessage.github),
            child: const Text("去 Git Release"),
          )
      ],
    );
  }
}
