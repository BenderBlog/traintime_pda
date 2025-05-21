// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:disclosure/disclosure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/repository/message_session.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class NoticeList extends StatelessWidget {
  const NoticeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BothSideSheet(
        title: FlutterI18n.translate(
          context,
          "homepage.notice_card.notice_list_title",
        ),
        child: DisclosureGroup(
          multiple: false,
          clearable: true,
          children: List<Widget>.generate(messages.length, (index) {
            return Disclosure(
              key: ValueKey('disclosure-$index'),
              wrapper: (state, child) {
                return Card.outlined(
                  clipBehavior: Clip.antiAlias,
                  child: child,
                );
              },
              header: DisclosureButton(
                child: ListTile(
                  title: Row(
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
                  trailing: const DisclosureSwitcher(
                    opened: Icon(Icons.arrow_drop_up),
                    closed: Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
              divider: const Divider(height: 1),
              child: Builder(builder: (context) {
                if (bool.tryParse(messages[index].isLink) ?? false) {
                  return FilledButton.icon(
                    onPressed: () => launchUrlString(
                      messages[index].message,
                      mode: LaunchMode.externalApplication,
                    ),
                    label: Text(FlutterI18n.translate(
                      context,
                      "homepage.notice_card.open_url",
                    )),
                    icon: const Icon(Icons.ads_click),
                  ).center();
                }
                return SelectableText(messages[index].message);
              }).padding(all: 12),
            );
          }),
        ).scrollable().padding(top: 20),
      ),
    );

    /*
      SimpleDialog(
        title: const Text(),
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
                    content: SelectableText(messages[index].message),
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
    );*/
  }
}
