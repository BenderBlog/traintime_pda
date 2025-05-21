// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
// import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/homepage/small_function_card.dart';

class SportCard extends StatelessWidget {
  const SportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        bool isGood = true;
        if (preference.getString(preference.Preference.sportPassword).isEmpty) {
          isGood = await showDialog<bool>(
                context: context,
                builder: (context) => const SportPasswordDialog(),
              ) ??
              false; // 当返回值为 null 时，设置 isGood 为 false
        }
        if (context.mounted && isGood) {
          context.pushReplacement(const SportWindow());
        }
      },
      icon: MingCuteIcons.mgc_run_fill,
      nameKey: "homepage.toolbox.sport",
    );
  }
}
