// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:watermeter/page/networkcard/network_card_window.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/schoolnet_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/network_session.dart' as network_session;

import 'package:ming_cute_icons/ming_cute_icons.dart';

class NetworkCard extends StatelessWidget {
  const NetworkCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (preference
            .getString(
              preference.Preference.schoolNetQueryPassword,
            )
            .isEmpty) {
          await showDialog(
            context: context,
            builder: (context) => const SchoolNetPasswordDialog(),
          );
        }
        if (context.mounted) {
          context.pushReplacement(const NetworkCardWindow());
        }
      },
      child: Obx(
        () => MainPageCard(
          isLoad: true,
          // network_session.isInit.value == SessionState.fetching,
          icon: MingCuteIcons.mgc_wifi_fill,
          text: preference
                  .getString(
                    preference.Preference.schoolNetQueryPassword,
                  )
                  .isEmpty
              ? FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.bill",
                )
              : "无校园网密码，点击设置",
          infoText: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: [
                if (network_session.isInit.value == SessionState.fetched) ...[
                  const TextSpan(text: "校园网余量"),
                  TextSpan(
                    text: "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else
                  TextSpan(
                    text: network_session.isInit.value == SessionState.error
                        ? "获取校园网流量信息失败"
                        : "正在获取校园网流量信息",
                  ),
              ],
            ),
          ),
          bottomText: Text(
            network_session.isInit.value == SessionState.fetched
                ? FlutterI18n.translate(
                    context,
                    "homepage.school_card_info_card.bottom_text_success",
                  )
                : network_session.isInit.value == SessionState.error
                    ? FlutterI18n.translate(
                        context,
                        "homepage.school_card_info_card.no_info",
                      )
                    : FlutterI18n.translate(
                        context,
                        "homepage.school_card_info_card.fetching_info",
                      ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
