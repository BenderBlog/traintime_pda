// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';

class SponsorshipCard extends StatelessWidget {
  const SponsorshipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(FlutterI18n.translate(context, "sponsorship.title"))
        .paddingDirectional(horizontal: 16, vertical: 14)
        .withHomeCardStyle(
          context,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  FlutterI18n.translate(context, "sponsorship.dialog_title"),
                ),
                content: Text(
                  FlutterI18n.translate(context, "sponsorship.dialog_content"),
                ).scrollable(),
                actions: [
                  TextButton(
                    onPressed: () =>
                        launchUrlString("https://join.geek-tech.club"),
                    child: Text(
                      FlutterI18n.translate(
                        context,
                        "sponsorship.button_jichuang",
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => launchUrlString(
                      "https://docs.qq.com/form/page/DRkFFcFJmc3FydVRF",
                    ),
                    child: Text(
                      FlutterI18n.translate(
                        context,
                        "sponsorship.button_xduna",
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }
}
