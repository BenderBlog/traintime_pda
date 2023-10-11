// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/message_observer.dart';
import 'package:watermeter/page/homepage/info_widget/notice_card/marquee_widget.dart';
import 'package:watermeter/page/homepage/info_widget/notice_card/notice_list.dart';
import 'package:watermeter/page/widget.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          if (messages.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => const NoticeList(),
            );
          } else {
            Fluttertoast.showToast(msg: "目前没有获取应用公告，请刷新");
          }
        },
        child: messages.isNotEmpty
            ? MarqueeWidget(
                itemCount: messages.length,
                itemBuilder: (context, index) => Row(
                  children: [
                    TagsBoxes(text: messages[index].type),
                    const SizedBox(width: 8),
                    Text(messages[index].title),
                  ],
                ),
              )
            : const Text("没有获取应用公告"),
      )
          .constrained(height: 30)
          .paddingDirectional(
            horizontal: 16,
            vertical: 14,
          )
          .decorated(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: isDesktop(context) ? BorderRadius.circular(12) : null,
          )
          .paddingAll(isDesktop(context) ? 4 : 0),
    );
  }
}
