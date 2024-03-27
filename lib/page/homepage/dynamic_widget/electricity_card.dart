// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/dynamic_widget/main_page_card.dart';
import 'package:watermeter/repository/electricity_session.dart'
    as electricity_session;
import 'package:watermeter/repository/xidian_ids/payment_session.dart'
    as owe_session;

class ElectricityCard extends StatelessWidget {
  const ElectricityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text("水电信息"),
            children: [
              Obx(
                () => Text(
                  "电费帐号：${electricity_session.ElectricitySession.electricityAccount()}\n"
                  "电量信息：${electricity_session.electricityInfo.value}"
                  "${electricity_session.electricityInfo.value.contains(RegExp(r'[0-9]')) ? "度电" : ""}\n"
                  "欠费信息：${owe_session.owe.value}\n"
                  "长按可以重新加载，有欠费一般代表水费",
                ),
              ).paddingSymmetric(horizontal: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("确定"),
              ).paddingSymmetric(horizontal: 24),
            ],
          ),
        );
      },
      onLongPress: () {
        electricity_session.update();
        owe_session.update();
      },
      child: Obx(
        () => MainPageCard(
          isLoad: electricity_session.isNotice.value,
          progress: electricity_session.electricityInfo.value
                  .contains(RegExp(r'[0-9]'))
              ? double.parse(electricity_session.electricityInfo.value) / 100.0
              : null,
          icon: MingCuteIcons.mgc_flash_line,
          text: "电量信息",
          infoText: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
              ),
              children: electricity_session.electricityInfo.value
                      .contains(RegExp(r'[0-9]'))
                  ? [
                      const TextSpan(text: "目前电量 "),
                      TextSpan(
                          text: double.parse(
                        electricity_session.electricityInfo.value,
                      ).truncate().toString()),
                      const TextSpan(text: " 度"),
                    ]
                  : [
                      TextSpan(
                        text: electricity_session.electricityInfo.value,
                      ),
                    ],
            ),
          ),
          bottomText: Text(
            owe_session.owe.value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
