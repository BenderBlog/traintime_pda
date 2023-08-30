// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/page/homepage/dynamic_widget/main_page_card.dart';
import 'package:watermeter/page/library/library_window.dart';
import 'package:watermeter/repository/network_session.dart';

class LibraryCard extends StatelessWidget {
  const LibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LibraryController>(
      builder: (c) => GestureDetector(
        onTap: () async {
          if (offline) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                "脱机模式下，一站式相关功能全部禁止使用",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ));
          } else if (!c.isGet.value) {
            if (c.error.value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "获取图书馆信息发生故障，长按该卡片获取更新",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "正在获取，请稍后再来看",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ));
            }
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LibraryWindow(),
              ),
            );
          }
        },
        onLongPress: () {
          if (offline) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("脱机模式下，一站式相关功能全部禁止使用"),
            ));
          } else if (!(c.isGet.value && !c.error.value)) {
            c.getBorrowList();
          }
        },
        child: Obx(
          () => MainPageCard(
            isLoad: !(c.isGet.value && !c.error.value),
            icon: MingCuteIcons.mgc_book_2_line,
            text: "图书借阅",
            infoText: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 20,
                ),
                children: c.isGet.value
                    ? [
                        TextSpan(
                          text: "${c.borrowList.length}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 28,
                          ),
                        ),
                        TextSpan(
                          text: " 本",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ]
                    : [
                        TextSpan(
                          text: c.error.value ? "发生错误" : "正在获取",
                        ),
                      ],
              ),
            ),
            bottomText: Obx(() {
              if (c.isGet.value) {
                return Text(c.dued == 0 ? "目前没有待归还书籍" : "待归还${c.dued}本书籍");
              } else {
                return Text(c.error.value ? "目前无法获取信息" : "正在查询信息中");
              }
            }),
          ),
        ),
      ),
    );
  }
}
