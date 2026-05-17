// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/schoolnet/network_card_window.dart';

class SchoolnetCard extends StatelessWidget {
  const SchoolnetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onPressed: () => context.pushReplacement(const NetworkCardWindow()),

      icon: MingCuteIcons.mgc_wifi_fill,
      nameKey: "homepage.toolbox.schoolnet",
    );
  }
}
