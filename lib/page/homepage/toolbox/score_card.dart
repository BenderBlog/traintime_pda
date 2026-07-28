// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/generated/translations.g.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onPressed: () {
        if (offline && !ScoreSession.isCacheExist) {
          showToast(
            context: context,
            msg: context.t.homepage.toolbox.scoreCannotReach,
          );
        } else {
          context.pushReplacementNamed(Routes.score);
        }
      },
      icon: Icons.grading_rounded,
      name: context.t.homepage.toolbox.score,
    );
  }
}
