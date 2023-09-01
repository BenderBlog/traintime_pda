// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/widget.dart';
import 'package:styled_widget/styled_widget.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("测试信息"),
              content: const Text(
                "酷安群拉群信息应某师傅请求。\n"
                "要聊最新数码，欢迎加入西电酷安3.0群\n"
                "要想膜拜大佬，欢迎加入西电微软俱乐部，这个是学校注册的正经社团。\n",
              ),
              actions: [
                TextButton(
                  onPressed: () => launchUrlString(
                    "https://mp.weixin.qq.com/s?__biz=MjM5NjExMzI0MA==&mid=2649794524&idx=1&sn=e5262e683810cb0df3978fa47a06b298",
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text("西电微软俱乐部招新"),
                ),
                TextButton(
                  onPressed: () => launchUrlString(
                    "https://qm.qq.com/cgi-bin/qm/qr?authKey=XrRF45qu7cF%2FTfiEuS7pn6PDtoFyoIsuQhDyCD%2FwWjRr1al5nSn%2Bb468VyS%2FmfVe&k=xspSEUneC_NMbZEcjcAFLnZgTLvO_ZAA&noverify=0",
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text("酷安群拉人链接"),
                ),
              ],
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TagsBoxes(text: "测试"),
            const VerticalDivider(color: Colors.transparent),
            Expanded(
              child: Text(
                "测试信息：西电微软俱乐部招新/西电酷安群拉人",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        )
            .paddingDirectional(
              horizontal: 16,
              vertical: 14,
            )
            .decorated(
              border: Border.all(
                width: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(26),
            )
            .paddingAll(4),
      ),
    );
  }
}
