// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';

class SponsorshipCard extends StatelessWidget {
  const SponsorshipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(context.t.sponsorship.title)
        .paddingDirectional(horizontal: 16, vertical: 14)
        .withHomeCardStyle(
          context,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(context.t.sponsorship.dialogTitle),
                content: Text(context.t.sponsorship.dialogContent).scrollable(),
                actions: [
                  TextButton(
                    onPressed: () =>
                        launchUrlString("https://join.geek-tech.club"),
                    child: Text(context.t.sponsorship.buttonJichuang),
                  ),
                  TextButton(
                    onPressed: () => launchUrlString(
                      "https://docs.qq.com/form/page/DRkFFcFJmc3FydVRF",
                    ),
                    child: Text(context.t.sponsorship.buttonXduna),
                  ),
                ],
              ),
            );
          },
        );
  }
}
