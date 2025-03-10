// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/networkcard/network_card_window.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class SchoolnetCard extends StatelessWidget {
  const SchoolnetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (preference
            .getString(preference.Preference.schoolNetQueryPassword)
            .isEmpty) {
          await showDialog(
            context: context,
            builder: (context) => const SchoolNetPasswordDialog(),
          ).then((value) {
            if (preference
                .getString(preference.Preference.schoolNetQueryPassword)
                .isNotEmpty) {
              update(
                captchaFunction: (image) => showDialog<String>(
                  context: context,
                  builder: (context) => CaptchaInputDialog(image: image),
                ).then((value) => value ?? ""),
              );
            }
          });
        }
        if (context.mounted) {
          context.pushReplacement(const NetworkCardWindow());
        }
      },
      child: Obx(
        () => MainPageCard(
          isLoad: schoolNetStatus.value == SessionState.fetching,
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
              : FlutterI18n.translate(
                  context,
                  "homepage.school_net.no_password",
                ),
          infoText: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: [
                if (schoolNetStatus.value == SessionState.fetched) ...[
                  TextSpan(
                    text: FlutterI18n.translate(
                      context,
                      "homepage.school_net.title",
                    ),
                  ),
                  const TextSpan(
                    text: "",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else
                  TextSpan(
                    text: FlutterI18n.translate(
                      context,
                      schoolNetStatus.value == SessionState.error
                          ? "homepage.school_net.failed"
                          : "homepage.school_net.fetching",
                    ),
                  ),
              ],
            ),
          ),
          bottomText: Text(
            schoolNetStatus.value == SessionState.fetched
                ? FlutterI18n.translate(
                    context, "homepage.school_net.remaining",
                    translationParams: {
                        "remaining": networkInfo.value!.rest,
                      })
                : schoolNetStatus.value == SessionState.error
                    ? FlutterI18n.translate(
                        context,
                        isError.value,
                      )
                    : FlutterI18n.translate(
                        context,
                        "homepage.school_net.fetching",
                      ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
