// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/homepage/notice_card/notice_page.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/repository/message_session.dart';
import 'package:watermeter/page/homepage/notice_card/marquee_widget.dart';
import 'package:watermeter/page/homepage/notice_card/notice_list.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          if (messages.isNotEmpty) {
            if (!isPhone(context)) {
              context.pushReplacement(const NoticePage());
            } else {
              showModalBottomSheet(
                context: context,
                builder: (context) => const NoticeList(),
              );
            }
          } else {
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                "homepage.notice_card.empty_notice",
              ),
            );
          }
        },
        child: messages.isNotEmpty
            ? MarqueeWidget(
                itemCount: messages.length,
                itemBuilder: (context, index) => Row(
                  children: [
                    TagsBoxes(text: messages[index].type),
                    const SizedBox(width: 8),
                    Text(
                      messages[index].title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ).expanded(),
                  ],
                ),
              )
            : Text(FlutterI18n.translate(
                context,
                "homepage.notice_card.no_notice_avaliable",
              )).center(),
      )
          .constrained(height: 30)
          .paddingDirectional(
            horizontal: 16,
            vertical: 14,
          )
          .withHomeCardStyle(context),
    );
  }
}
