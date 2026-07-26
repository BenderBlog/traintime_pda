// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:watermeter/page/public_widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/schoolcard/qr_code_view.dart';
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/generated/l10n.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';

class SchoolCardInfoCard extends StatelessWidget {
  const SchoolCardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final state = SchoolCardController.i.moneyStateSignal.value;
        return MainPageCard(
          onPressed: () async {
            if (offline) {
              showToast(
                context: context,
                msg: I18n.of(context)!.homepageOfflineMode,
              );
            } else {
              state.map(
                data: (_) {
                  context.pushReplacementNamed(Routes.schoolCard);
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
                    msg: I18n.of(context)!.homepageSchoolCardInfoCardErrorToast,
                  );
                },
                loading: () {
                  showToast(
                    context: context,
                    msg: I18n.of(
                      context,
                    )!.homepageSchoolCardInfoCardFetchingToast,
                  );
                },
                refreshing: () {
                  showToast(
                    context: context,
                    msg: I18n.of(
                      context,
                    )!.homepageSchoolCardInfoCardFetchingToast,
                  );
                },
                reloading: () {
                  showToast(
                    context: context,
                    msg: I18n.of(
                      context,
                    )!.homepageSchoolCardInfoCardFetchingToast,
                  );
                },
              );
            }
          },
          isLoad: state.isLoading,
          icon: MingCuteIcons.mgc_wallet_4_line,
          text: I18n.of(context)!.homepageSchoolCardInfoCardBill,
          infoText: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: [
                TextSpan(
                  text: state.map(
                    data: (money) {
                      if (money.contains(RegExp(r'[0-9]'))) {
                        return I18n.of(
                          context,
                        )!.homepageSchoolCardInfoCardBalance(
                          double.parse(money) >= 10
                              ? double.parse(money).truncate().toString()
                              : money,
                        );
                      }
                      return I18n.of(context)!.schoolCardStatusFailedToQuery;
                    },
                    loading: () =>
                        I18n.of(context)!.homepageSchoolCardInfoCardFetching,
                    refreshing: () =>
                        I18n.of(context)!.homepageSchoolCardInfoCardFetching,
                    reloading: () =>
                        I18n.of(context)!.homepageSchoolCardInfoCardFetching,
                    error: (_, stackTrace) => I18n.of(
                      context,
                    )!.homepageSchoolCardInfoCardErrorOccured,
                  ),
                ),
              ],
            ),
          ),
          bottomText: Text(
            state.map(
              data: (_) =>
                  I18n.of(context)!.homepageSchoolCardInfoCardBottomTextSuccess,
              loading: () =>
                  I18n.of(context)!.homepageSchoolCardInfoCardFetchingInfo,
              refreshing: () =>
                  I18n.of(context)!.homepageSchoolCardInfoCardFetchingInfo,
              reloading: () =>
                  I18n.of(context)!.homepageSchoolCardInfoCardFetchingInfo,
              error: (_, stackTrace) =>
                  I18n.of(context)!.homepageSchoolCardInfoCardNoInfo,
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
      },
    );
  }
}
