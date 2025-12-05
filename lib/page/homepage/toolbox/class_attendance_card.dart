// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/class_attendance/class_attendance_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';

class ClassAttendanceCard extends StatelessWidget {
  const ClassAttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        if (offline) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "homepage.offline_mode"),
          );
        } else {
          context.pushReplacement(const ClassAttendanceView());
        }
      },
      icon: Icons.punch_clock_outlined,
      nameKey: "homepage.toolbox.class_attendance",
    );
  }
}
