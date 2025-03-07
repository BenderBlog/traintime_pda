// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Python script by arttnba3

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EasterEggPage extends StatefulWidget {
  const EasterEggPage({super.key});

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  // Gimme Shelter - Rolling Stongs - Let it bleed...
  final String urlTC = "https://www.bilibili.com/video/BV1mt411p7bZ/";

  // The Sky is Crying - Elmore James arr. Eric Clapton - There's one in every crowd
  final String urlSC = "https://www.bilibili.com/video/BV1S841187nW?t=952.7";

  // Take it to the Limit - Eagles - One of these nights.
  final String urlEnglish = "https://www.bilibili.com/video/BV1yd4y1v7Xg";

  @override
  Widget build(BuildContext context) {
    String langtag =
        FlutterI18n.currentLocale(context)?.toLanguageTag() ?? "und";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            "setting.easter_egg_page",
          ),
        ),
      ),
      body: [
        [
          IconButton.filled(
            onPressed: () => launchUrl(
              Uri.parse(
                langtag.contains("en")
                    ? urlEnglish
                    : langtag.contains("tw")
                        ? urlTC
                        : urlSC,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
          const SizedBox(width: 24),
          IconButton.filledTonal(
            onPressed: () => launchUrl(
              Uri.parse(
                langtag.contains("en")
                    ? urlSC
                    : langtag.contains("tw")
                        ? urlSC
                        : urlTC,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
          const SizedBox(width: 24),
          IconButton.filledTonal(
            onPressed: () => launchUrl(
              Uri.parse(
                langtag.contains("en")
                    ? urlTC
                    : langtag.contains("tw")
                        ? urlEnglish
                        : urlEnglish,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(all: 24.0),
        Text(
          FlutterI18n.translate(context, "easter_egg"),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Image.asset("assets/art/pda_girl_default.png"),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
          .scrollable()
          .center()
          .padding(horizontal: 16)
          .safeArea(),
    );
  }
}
