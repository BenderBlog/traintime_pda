// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
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
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              "homepage.offline_mode",
            ),
          );
        } else {
          switch (school_card_session.isInit.value) {
            case SessionState.fetched:
              context.pushReplacement(const SchoolCardWindow());
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

              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.error_toast",
                ),
              );
              break;
            default:
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.fetching_toast",
                ),
              );
          }
        }
      },
      onLongPress: () async {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return FutureBuilder<Uint8List>(
              future: school_card_session.SchoolCardSession().getQRCode(),
              builder: (context, snapshot) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        color: Colors.white.withOpacity(0.85),
                        child: snapshot.connectionState ==
                                ConnectionState.waiting
                            ? const SizedBox(
                                width: 120,
                                height: 120,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : snapshot.hasError
                                ? SizedBox(
                                    width: 200,
                                    child: Text(
                                      "二维码获取失败: ${snapshot.error}",
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  )
                                : Image.memory(
                                    snapshot.data!,
                                    width: 200,
                                    height: 200,
                                  ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      child: Obx(
        () => MainPageCard(
          isLoad: school_card_session.isInit.value == SessionState.fetching,
          icon: MingCuteIcons.mgc_wallet_4_line,
          text: FlutterI18n.translate(
            context,
            "homepage.school_card_info_card.bill",
          ),
          infoText: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: [
                if (school_card_session.isInit.value ==
                    SessionState.fetched) ...[
                  if (school_card_session.money.value
                      .contains(RegExp(r'[0-9]')))
                    TextSpan(
                      text: FlutterI18n.translate(
                          context, "homepage.school_card_info_card.balance",
                          translationParams: {
                            "amount": double.parse(
                                      school_card_session.money.value,
                                    ) >=
                                    10
                                ? double.parse(school_card_session.money.value)
                                    .truncate()
                                    .toString()
                                : school_card_session.money.value,
                          }),
                    )
                  else
                    TextSpan(
                      text: FlutterI18n.translate(
                        context,
                        school_card_session.money.value,
                      ),
                    ),
                ] else
                  TextSpan(
                    text: school_card_session.isInit.value == SessionState.error
                        ? FlutterI18n.translate(
                            context,
                            "homepage.school_card_info_card.error_occured",
                          )
                        : FlutterI18n.translate(
                            context,
                            "homepage.school_card_info_card.fetching",
                          ),
                  ),
              ],
            ),
          ),
          bottomText: Text(
            school_card_session.isInit.value == SessionState.fetched
                ? FlutterI18n.translate(
                    context,
                    "homepage.school_card_info_card.bottom_text_success",
                  )
                : school_card_session.isInit.value == SessionState.error
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
