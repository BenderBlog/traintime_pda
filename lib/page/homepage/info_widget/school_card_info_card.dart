// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/schoolcard/qr_code_view.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';

class SchoolCardInfoCard extends StatelessWidget {
  const SchoolCardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SchoolCardController.i.moneyStateSignal.watch(context);
    return MainPageCard(
      onPressed: () async {
        if (offline) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "homepage.offline_mode"),
          );
        } else {
          state.map(
            data: (_) {
              context.pushReplacement(const SchoolCardWindow());
            },
            error: (errorStatus, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    errorStatus.toString().substring(
                      0,
                      min(errorStatus.toString().length, 120),
                    ),
                  ),
                ),
              );

              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.error_toast",
                ),
              );
            },
            loading: () {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.fetching_toast",
                ),
              );
            },
            refreshing: () {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.fetching_toast",
                ),
              );
            },
            reloading: () {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.fetching_toast",
                ),
              );
            },
          );
        }
      },
      isLoad: state.isLoading,
      icon: MingCuteIcons.mgc_wallet_4_line,
      text: FlutterI18n.translate(
        context,
        "homepage.school_card_info_card.bill",
      ),
      infoText: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 20),
          children: [
            TextSpan(
              text: state.map(
                data: (money) {
                  if (money.contains(RegExp(r'[0-9]'))) {
                    return FlutterI18n.translate(
                      context,
                      "homepage.school_card_info_card.balance",
                      translationParams: {
                        "amount": double.parse(money) >= 10
                            ? double.parse(money).truncate().toString()
                            : money,
                      },
                    );
                  }
                  return FlutterI18n.translate(context, money);
                },
                loading: () => FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.fetching",
                ),
                refreshing: () => FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.fetching",
                ),
                reloading: () => FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.fetching",
                ),
                error: (_, stackTrace) => FlutterI18n.translate(
                  context,
                  "homepage.school_card_info_card.error_occured",
                ),
              ),
            ),
          ],
        ),
      ),
      bottomText: Text(
        state.map(
          data: (_) => FlutterI18n.translate(
            context,
            "homepage.school_card_info_card.bottom_text_success",
          ),
          loading: () => FlutterI18n.translate(
            context,
            "homepage.school_card_info_card.fetching_info",
          ),
          refreshing: () => FlutterI18n.translate(
            context,
            "homepage.school_card_info_card.fetching_info",
          ),
          reloading: () => FlutterI18n.translate(
            context,
            "homepage.school_card_info_card.fetching_info",
          ),
          error: (_, stackTrace) => FlutterI18n.translate(
            context,
            "homepage.school_card_info_card.no_info",
          ),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      rightButton: state.hasValue
          ? IconButton.filledTonal(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return QRCodeView();
                  },
                );
              },
              icon: Icon(Icons.qr_code_2),
            )
          : null,
    );
  }
}
