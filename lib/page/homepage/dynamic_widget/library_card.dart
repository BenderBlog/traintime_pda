// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as borrow_info;
import 'package:watermeter/page/homepage/dynamic_widget/main_page_card.dart';
import 'package:watermeter/page/library/library_window.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class LibraryCard extends StatelessWidget {
  const LibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (offline) {
          Fluttertoast.showToast(msg: "脱机模式下，一站式相关功能全部禁止使用");
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LibraryWindow(),
            ),
          );
        }
      },
      child: Obx(
        () => MainPageCard(
          isLoad: borrow_info.state.value == SessionState.fetching,
          icon: MingCuteIcons.mgc_book_2_line,
          text: "图书借阅",
          infoText: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
              ),
              children: [
                if (borrow_info.state.value == SessionState.fetched) ...[
                  TextSpan(
                    text: "${borrow_info.borrowList.length}",
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const TextSpan(text: " 本"),
                ] else if (borrow_info.state.value == SessionState.error)
                  const TextSpan(text: "发生错误")
                else
                  const TextSpan(text: "正在获取")
              ],
            ),
          ),
          bottomText: Obx(() {
            return DefaultTextStyle.merge(
              overflow: TextOverflow.ellipsis,
              child: Text(
                borrow_info.state.value == SessionState.fetched
                    ? borrow_info.dued == 0
                        ? "目前没有待归还书籍"
                        : "待归还${borrow_info.dued}本书籍"
                    : borrow_info.state.value == SessionState.error
                        ? "目前无法获取信息"
                        : "正在查询信息中",
              ),
            );
          }),
        ),
      ),
    );
  }
}
