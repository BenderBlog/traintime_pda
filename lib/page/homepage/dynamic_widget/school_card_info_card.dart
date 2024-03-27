// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/dynamic_widget/main_page_card.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart'
    as school_card_session;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';

class SchoolCardInfoCard extends StatelessWidget {
  const SchoolCardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (offline) {
          Fluttertoast.showToast(msg: "脱机模式下，一站式相关功能全部禁止使用");
        } else {
          switch (school_card_session.isInit.value) {
            case SessionState.fetched:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SchoolCardWindow(),
                ),
              );
              break;
            case SessionState.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(school_card_session.errorSession.substring(
                    0,
                    min(
                      school_card_session.errorSession.value.length,
                      120,
                    ),
                  )),
                ),
              );

              Fluttertoast.showToast(msg: "遇到错误，请联系开发者");
              break;
            default:
              Fluttertoast.showToast(msg: "正在获取信息，请稍后再来看");
          }
        }
      },
      child: Obx(
        () => MainPageCard(
          isLoad: school_card_session.isInit.value == SessionState.fetching,
          icon: MingCuteIcons.mgc_wallet_4_line,
          text: "流水",
          infoText: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
              ),
              children: [
                if (school_card_session.isInit.value ==
                    SessionState.fetched) ...[
                  if (school_card_session.money.value
                      .contains(RegExp(r'[0-9]')))
                    const TextSpan(text: "校园卡余额 "),
                  TextSpan(
                    text: school_card_session.money.value
                            .contains(RegExp(r'[0-9]'))
                        ? double.parse(school_card_session.money.value) >= 10
                            ? double.parse(school_card_session.money.value)
                                .truncate()
                                .toString()
                            : school_card_session.money.value
                        : school_card_session.money.value,
                  ),
                  if (school_card_session.money.value
                      .contains(RegExp(r'[0-9]')))
                    const TextSpan(text: " 元"),
                ] else
                  TextSpan(
                    text: school_card_session.isInit.value == SessionState.error
                        ? "获取校园卡信息发生错误"
                        : "正在获取校园卡信息",
                  ),
              ],
            ),
          ),
          bottomText: Text(
            school_card_session.isInit.value == SessionState.fetched
                ? "查询一卡通流水"
                : school_card_session.isInit.value == SessionState.error
                    ? "目前无法获取信息"
                    : "正在查询信息中",
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
