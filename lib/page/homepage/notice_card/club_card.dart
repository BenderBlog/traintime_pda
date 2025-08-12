// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/pda_service_session.dart';
import 'package:watermeter/page/homepage/notice_card/marquee_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class ClubPromotionCard extends StatelessWidget {
  final Function()? onTap;
  const ClubPromotionCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
          switch (clubState.value) {
            case SessionState.fetched:
              return MarqueeWidget(
                itemCount: clubList.length,
                itemBuilder: (context, index) => Row(
                  children: [
                    TagsBoxes(text: getTypeName(clubList[index].type.first)),
                    const SizedBox(width: 8),
                    Text(
                      clubList[index].title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ).expanded(),
                  ],
                ),
              );

            case SessionState.error:
              return Text("社团信息获取失败").center();
            default:
              return Text("社团信息清单正在加载").center();
          }
        })
        .constrained(height: 30)
        .paddingDirectional(horizontal: 16, vertical: 14)
        .withHomeCardStyle(context)
        .gestures(onTap: onTap);
  }
}
