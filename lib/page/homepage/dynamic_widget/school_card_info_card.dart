// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/page/homepage/dynamic_widget/main_page_card.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';
import 'package:watermeter/repository/network_session.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';

class SchoolCardInfoCard extends StatelessWidget {
  const SchoolCardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchoolCardController>(
      builder: (c) => GestureDetector(
        onTap: () async {
          if (offline) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("脱机模式下，一站式相关功能全部禁止使用"),
            ));
          } else if (c.errorPrice.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("遇到错误：${c.errorPrice}"),
            ));
          } else if (!c.isGetPrice.value) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("仍然在加载中"),
            ));
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SchoolCardWindow(),
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
          } else {
            c.updateMoney();
          }
        },
        child: Obx(
          () => MainPageCard(
            isLoad: !(c.isGetPrice.value && c.errorPrice.isEmpty),
            icon: MingCuteIcons.mgc_wallet_4_line,
            text: "流水查询",
            infoText: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 20,
                ),
                children: c.isGetPrice.value
                    ? [
                        TextSpan(
                          text: c.money.value.contains(RegExp(r'[0-9]'))
                              ? double.parse(c.money.value) >= 10
                                  ? double.parse(c.money.value)
                                      .truncate()
                                      .toString()
                                  : c.money.value
                              : c.money.value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: c.money.value.contains(RegExp(r'[0-9]'))
                                ? 28
                                : 20,
                          ),
                        ),
                        if (c.money.value.contains(RegExp(r'[0-9]')))
                          TextSpan(
                            text: " 元",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ]
                    : [
                        TextSpan(
                          text: c.errorPrice.isNotEmpty ? "发生错误" : "正在获取",
                        ),
                      ],
              ),
            ),
            bottomText: Obx(
              () => Text(
                c.isGetPrice.value
                    ? "点开查询流水"
                    : c.errorPrice.isNotEmpty
                        ? "目前无法获取信息"
                        : "正在查询信息中",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
