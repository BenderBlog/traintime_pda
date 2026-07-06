// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/routing/routes.dart';

class EmptyClassroomCard extends StatelessWidget {
  const EmptyClassroomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onPressed: () async {
        if (offline) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "homepage.offline_mode"),
          );
        } else {
          context.pushReplacementNamed(Routes.emptyClassroom);
        }
      },
      icon: MingCuteIcons.mgc_building_2_line,
      nameKey: "homepage.toolbox.empty_classroom",
    );
  }
}
