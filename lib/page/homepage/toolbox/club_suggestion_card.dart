// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/club_suggestion/club_suggestion.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';

class ClubSuggestionCard extends StatelessWidget {
  const ClubSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        if (offline) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              "homepage.offline_mode",
            ),
          );
        } else {
          context.pushReplacement(const ClubSuggestion());
        }
      },
      icon: MingCuteIcons.mgc_clubs_fill,
      nameKey: "社团推荐",
    );
  }
}
