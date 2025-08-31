// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/electricity/electricity_window.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/xidian_ids/electricity_session.dart';

class ElectricityCard extends StatelessWidget {
  const ElectricityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () async {
          context.push(ElectricityWindow());
        },
        child: MainPageCard(
          isLoad: isLoad.value,
          icon: MingCuteIcons.mgc_flash_line,
          text: FlutterI18n.translate(
            context,
            "homepage.electricity_card.title",
          ),
          infoText: Text(
            electricityInfo.value.remain.contains(RegExp(r'[0-9]'))
                ? FlutterI18n.translate(
                    context,
                    "homepage.electricity_card.current_electricity",
                    translationParams: {"amount": electricityInfo.value.remain},
                  )
                : FlutterI18n.translate(context, electricityInfo.value.remain),
            style: const TextStyle(fontSize: 20),
          ),
          bottomText: Builder(
            builder: (context) {
              /// I believe it is not from tomorrow, like Bender lol
              if (!electricityInfo.value.fetchDay.isToday) {
                return Text(
                  FlutterI18n.translate(
                    context,
                    "homepage.electricity_card.cache_notice",
                    translationParams: {
                      "date": DateFormat(
                        "yyyy-MM-dd HH:mm",
                      ).format(electricityInfo.value.fetchDay),
                    },
                  ).replaceAll("\n", ""),
                );
              }

              if (electricityInfo.value.owe.contains(RegExp(r'[0-9]'))) {
                return Text(
                  FlutterI18n.translate(
                    context,
                    "electricity_status.owe_need_pay",
                    translationParams: {"due": electricityInfo.value.owe},
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              }
              return Text(
                FlutterI18n.translate(context, electricityInfo.value.owe),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),
      ),
    );
  }
}
