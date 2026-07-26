// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

/*
import 'package:watermeter/controller/schoolnet_controller.dart';
import 'package:watermeter/page/schoolnet/network_card_window.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/generated/l10n.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';

class SchoolnetCard extends StatelessWidget {
  const SchoolnetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SchoolnetController.i.schoolNetUsageStateSignal.watch(
      context,
    );
    return MainPageCard(
      onPressed: () async {
        context.pushReplacement(const NetworkCardWindow());
      },
      isLoad: state.isLoading,
      icon: MingCuteIcons.mgc_wifi_fill,
      text:
          preference
              .getString(preference.Preference.schoolNetQueryPassword)
              .isEmpty
          ? I18n.of(context)!.homepageSchoolCardInfoCardBill
          : I18n.of(context)!.homepageSchoolNetNoPassword,
      infoText: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 20),
          children: [
            TextSpan(
              text: state.map(
                data: (result) => I18n.of(context)!.homepageSchoolNetTitle(result.data.used.replaceAll("G", " GB")),
                loading: () => I18n.of(context)!.homepageSchoolNetFetching,
                refreshing: () => I18n.of(context)!.homepageSchoolNetFetching,
                reloading: () => I18n.of(context)!.homepageSchoolNetFetching,
                error: (_, _) => I18n.of(context)!.homepageSchoolNetFailed,
              ),
            ),
          ],
        ),
      ),
      bottomText: Text(
        state.map(
          data: (result) => I18n.of(context)!.homepageSchoolNetRemaining(result.data.charged),
          loading: () =>
              I18n.of(context)!.homepageSchoolNetFetching,
          refreshing: () =>
              I18n.of(context)!.homepageSchoolNetFetching,
          reloading: () =>
              I18n.of(context)!.homepageSchoolNetFetching,
          error: (errorStatus, _) => errorStatus is String
              ? FlutterI18n.translate(context, errorStatus)
              : I18n.of(context)!.homepageSchoolNetFailed,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
*/
