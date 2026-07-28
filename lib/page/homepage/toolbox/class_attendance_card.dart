// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/page/public_widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/generated/translations.g.dart';

class ClassAttendanceCard extends StatelessWidget {
  const ClassAttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onPressed: () async {
        if (offline) {
          showToast(
            context: context,
            msg: context.t.homepage.offlineMode,
          );
        } else {
          context.pushReplacementNamed(Routes.classAttendance);
        }
      },
      icon: Icons.punch_clock_outlined,
      name: context.t.homepage.toolbox.classAttendance,
    );
  }
}
