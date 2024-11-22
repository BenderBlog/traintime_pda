// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/setting/dialogs/electricity_account_dialog.dart';
import 'package:watermeter/repository/preference.dart' as prefs;
import 'package:watermeter/repository/xidian_ids/payment_session.dart';

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
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: Text(FlutterI18n.translate(
                context,
                "homepage.electricity_card.title",
              )),
              children: [
                Obx(
                  () => Text.rich(
                    TextSpan(children: [
                      if (isCache.value)
                        TextSpan(
                          text: FlutterI18n.translate(
                            context,
                            "homepage.electricity_card.cache_notice",
                            translationParams: {
                              "date": Jiffy.parseFromDateTime(
                                electricityInfo.value.fetchDay,
                              ).format(
                                pattern: "yyyy-MM-dd HH:mm:ss",
                              ),
                            },
                          ),
                        ),
                      TextSpan(
                        text: FlutterI18n.translate(
                          context,
                          "homepage.electricity_card.dialog_content",
                          translationParams: {
                            "account":
                                PaymentSession.electricityAccount().toString(),
                            "electricityInfo": "${FlutterI18n.translate(
                              context,
                              electricityInfo.value.remain,
                            )}${electricityInfo.value.remain.contains(RegExp(r'[0-9]')) ? " kWh" : ""}",
                            "owe": FlutterI18n.translate(
                              context,
                              electricityInfo.value.owe,
                            ),
                          },
                        ),
                      ),
                    ]),
                  ),
                ).paddingSymmetric(horizontal: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(FlutterI18n.translate(
                    context,
                    "confirm",
                  )),
                ).paddingSymmetric(horizontal: 24),
              ],
            ),
          );
        }
      },
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
          bottomText: Text(
            FlutterI18n.translate(
              context,
              electricityInfo.value.owe,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          rightButton: IconButton.outlined(
            onPressed: () => update(
              captchaFunction: (image) => showDialog<String>(
                context: context,
                builder: (context) => CaptchaInputDialog(image: image),
              ).then((value) => value ?? ""),
            ),
            style: IconButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            icon: Icon(
              Icons.refresh_rounded,
              color: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
