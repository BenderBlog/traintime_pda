// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';
//import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
//import 'package:watermeter/page/public_widget/toast.dart';

class EasterEggPage extends StatefulWidget {
  const EasterEggPage({super.key});

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  //int counter = 0;

  bool isNotApple = (!Platform.isIOS && !Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNotApple ? "Merry Xmas" : "Early Sakura",
        ), //Text(FlutterI18n.translate(context, "easter_egg_robot.appbar")),
      ),
      body: LayoutBuilder(
        builder: (context, constraits) {
          if (isNotApple) {
            return SnowFallView(
              minBrightness: 0.2,
              viewSize: Size(constraits.maxWidth, constraits.maxHeight),
              fps: 60,
              child: Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: Image.asset("assets/art/anan_christmas.png"),
              ),
            ).decorated(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[900]!, Colors.blue[700]!],
              ),
            );
          } else {
            return SakuraBlizzardView(
              viewSize: Size(constraits.maxWidth, constraits.maxHeight),
              fps: 60,
              frontObjNum: 30,
              backObjNum: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints.expand(),
                child: Image.asset(
                  "assets/art/Sakura_and_Tomoyo_Kimono.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        },
      ),

      /*[
        Image.asset("assets/art/aboutRobots-icon.png"),
        const SizedBox(height: 24),
        Text(
          FlutterI18n.translate(context, "easter_egg_robot.title"),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Text(FlutterI18n.translate(context, "easter_egg_robot.contents")),
        Visibility(
          visible: counter <= 1,
          child: TextButton(
            onPressed: () {
              setState(() {
                counter += 1;
              });
              if (counter > 1) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "easter_egg_robot.button_notice",
                  ),
                );
              }
            },
            child: Text(
              FlutterI18n.translate(
                context,
                counter == 0
                    ? "easter_egg_robot.button_one"
                    : "easter_egg_robot.button_two",
              ),
            ),
          ),
        ),
      ].toColumn().scrollable().center().padding(horizontal: 16),*/
    );
  }
}
