// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/routing/routes.dart';

class ExperimentCard extends StatelessWidget {
  const ExperimentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onPressed: () async {
        context.pushReplacementNamed(Routes.experiment);
      },
      icon: MingCuteIcons.mgc_science_line,
      nameKey: "homepage.toolbox.experiment",
    );
  }
}
