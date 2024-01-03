// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/repository/message_session.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class NoticeList extends StatelessWidget {
  const NoticeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SimpleDialog(
        title: const Text("应用信息"),
        children: List.generate(
          messages.length,
          (index) => SimpleDialogOption(
            onPressed: () {
              if (bool.parse(messages[index].isLink)) {
                launchUrlString(
                  messages[index].message,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(messages[index].title),
                    content: Text(messages[index].message),
                  ),
                );
              }
            },
            child: Row(
              children: [
                TagsBoxes(text: messages[index].type),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    messages[index].title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
