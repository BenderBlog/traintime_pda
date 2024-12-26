// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Python script by arttnba3

import 'dart:io';

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
  final String urlApple = "https://www.bilibili.com/video/BV1Ab411T7TB/?p=2";

  final String urlOthers = "https://www.bilibili.com/video/BV1Cs411272t/";

  @override
  Widget build(BuildContext context) {
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
                Platform.isIOS || Platform.isMacOS ? urlApple : urlOthers,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
          const SizedBox(width: 48),
          IconButton.filledTonal(
            onPressed: () => launchUrl(
              Uri.parse(
                Platform.isIOS || Platform.isMacOS ? urlOthers : urlApple,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(all: 16.0),
        Text(FlutterI18n.translate(context, "easter_egg")),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
          .scrollable()
          .center()
          .padding(horizontal: 16)
          .safeArea(),
    );
  }
}
