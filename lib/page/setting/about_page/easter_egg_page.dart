// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/generated/translations.g.dart';

class EasterEggPage extends StatefulWidget {
  const EasterEggPage({super.key});

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  int counter = 0;

  bool isNotApple = (!Platform.isIOS && !Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.easterEggRobot.appbar),
      ),
      body: [
        if (counter > 1)
          Image.asset("assets/art/Doraemon_character.png", scale: 3)
        else
          Image.asset("assets/art/aboutRobots-icon.png"),
        const SizedBox(height: 24),
        Text(
          context.t.easterEggRobot.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Text(context.t.easterEggRobot.contents),
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
                  msg: context.t.easterEggRobot.buttonNotice,
                );
              }
            },
            child: Text(
              counter == 0
                  ? context.t.easterEggRobot.buttonOne
                  : context.t.easterEggRobot.buttonTwo,
            ),
          ),
        ),
      ].toColumn().scrollable().center().padding(horizontal: 16),
    );
  }
}
