// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/electricity/electricity_window.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/dialogs/electricity_account_dialog.dart';
import 'package:watermeter/repository/preference.dart' as prefs;
import 'package:watermeter/repository/xidian_ids/electricity_session.dart';

class ElectricityCard extends StatelessWidget {
  const ElectricityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (prefs.getString(prefs.Preference.dorm).isEmpty) {
          showDialog(
            context: context,
            builder: (context) => ElectricityAccountDialog(),
          ).then((value) {
            if (prefs.getString(prefs.Preference.dorm).isNotEmpty) {
              update(
                captchaFunction: (image) => showDialog<String>(
                  context: context,
                  builder: (context) => CaptchaInputDialog(image: image),
                ).then((value) => value ?? ""),
              );
            }
          });
        } else {
          context.push(ElectricityWindow());
          //showDialog(
          //  context: context,
          //  builder: (context) => AlertDialog(
          //    title: Text(FlutterI18n.translate(
          //      context,
          //      "homepage.electricity_card.title",
          //    )),
          //    content: Obx(
          //      () => Text.rich(
          //        TextSpan(children: [
          //          if (isCache.value &&
          //              !electricityInfo.value.fetchDay.isToday)
          //            TextSpan(
          //              text: FlutterI18n.translate(
          //                context,
          //                "homepage.electricity_card.cache_notice",
          //                translationParams: {
          //                  "date": Jiffy.parseFromDateTime(
          //                    electricityInfo.value.fetchDay,
          //                  ).format(
          //                    pattern: "yyyy-MM-dd HH:mm:ss",
          //                  ),
          //                },
          //              ),
          //            ),
          //          TextSpan(
          //            text: FlutterI18n.translate(
          //              context,
          //              "homepage.electricity_card.dialog_content",
          //              translationParams: {
          //                "account": ElectricitySession.electricityAccount()
          //                    .toString(),
          //                "electricityInfo": "${FlutterI18n.translate(
          //                  context,
          //                  electricityInfo.value.remain,
          //                )}${electricityInfo.value.remain.contains(RegExp(r'[0-9]')) ? " kWh" : ""}",
          //                "owe": FlutterI18n.translate(
          //                  context,
          //                  electricityInfo.value.owe,
          //                ),
          //              },
          //            ),
          //          ),
          //          TextSpan(
          //            text: historyElectricityInfo
          //                .map(
          //                  (e) =>
          //                      "${Jiffy.parseFromDateTime(e.fetchDay).format(pattern: "yyyy-MM-dd")} "
          //                      "${e.remain}",
          //                )
          //                .toString(),
          //          ),
          //        ]),
          //      ),
          //    ),
          //    actions: [
          //      TextButton(
          //        onPressed: () => Navigator.of(context).pop(),
          //        child: Text(FlutterI18n.translate(
          //          context,
          //          "confirm",
          //        )),
          //      ),
          //    ],
          //  ),
          //);
        }
      },
      onLongPress: () => update(
        force: true,
        captchaFunction: (image) => showDialog<String>(
          context: context,
          builder: (context) => CaptchaInputDialog(image: image),
        ).then((value) => value ?? ""),
      ),
      child: Obx(
        () => MainPageCard(
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
                      translationParams: {
                        "amount": electricityInfo.value.remain,
                      },
                    )
                  : FlutterI18n.translate(
                      context,
                      electricityInfo.value.remain,
                    ),
              style: const TextStyle(fontSize: 20),
            ),
            bottomText: Builder(builder: (context) {
              /// I believe it is not from tomorrow, like Bender lol
              if (!electricityInfo.value.fetchDay.isToday) {
                return Text(FlutterI18n.translate(
                  context,
                  "homepage.electricity_card.cache_notice",
                  translationParams: {
                    "date": Jiffy.parseFromDateTime(
                      electricityInfo.value.fetchDay,
                    ).format(
                      pattern: "yyyy-MM-dd HH:mm",
                    ),
                  },
                ).replaceAll("\n", ""));
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
                FlutterI18n.translate(
                  context,
                  electricityInfo.value.owe,
                ),
                overflow: TextOverflow.ellipsis,
              );
            })),
      ),
    );
  }
}
