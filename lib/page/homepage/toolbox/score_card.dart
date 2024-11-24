// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () {
        if (offline && !ScoreSession.isCacheExist) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              "homepage.toolbox.score_cannot_reach",
            ),
          );
        } else {
          context.pushReplacement(const ScoreWindow());
        }
      },
      icon: Icons.grading_rounded,
      nameKey: "homepage.toolbox.score",
    );
  }
}
