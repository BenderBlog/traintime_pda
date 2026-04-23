// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/schoolnet_controller.dart';
import 'package:watermeter/page/schoolnet/network_card_window.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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
          ? FlutterI18n.translate(
              context,
              "homepage.school_card_info_card.bill",
            )
          : FlutterI18n.translate(context, "homepage.school_net.no_password"),
      infoText: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 20),
          children: [
            TextSpan(
              text: state.map(
                data: (result) => FlutterI18n.translate(
                  context,
                  "homepage.school_net.title",
                  translationParams: {
                    "usage": result.data.used.replaceAll("G", " GB"),
                  },
                ),
                loading: () => FlutterI18n.translate(
                  context,
                  "homepage.school_net.fetching",
                ),
                refreshing: () => FlutterI18n.translate(
                  context,
                  "homepage.school_net.fetching",
                ),
                reloading: () => FlutterI18n.translate(
                  context,
                  "homepage.school_net.fetching",
                ),
                error: (_, _) => FlutterI18n.translate(
                  context,
                  "homepage.school_net.failed",
                ),
              ),
            ),
          ],
        ),
      ),
      bottomText: Text(
        state.map(
          data: (result) => FlutterI18n.translate(
            context,
            "homepage.school_net.remaining",
            translationParams: {"remaining": result.data.charged},
          ),
          loading: () =>
              FlutterI18n.translate(context, "homepage.school_net.fetching"),
          refreshing: () =>
              FlutterI18n.translate(context, "homepage.school_net.fetching"),
          reloading: () =>
              FlutterI18n.translate(context, "homepage.school_net.fetching"),
          error: (errorStatus, _) => errorStatus is String
              ? FlutterI18n.translate(context, errorStatus)
              : FlutterI18n.translate(context, "homepage.school_net.failed"),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
