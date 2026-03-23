// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/dorm_water/dorm_water_window.dart';

class DormWaterCard extends StatelessWidget {
  const DormWaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onPressed: () async {
        context.pushReplacement(const DormWaterWindow());
      },
      icon: MingCuteIcons.mgc_teacup_line,
      nameKey: "homepage.toolbox.dorm_water",
    );
  }
}
