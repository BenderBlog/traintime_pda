// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';
import 'package:watermeter/page/lost_and_found/lost_and_found_page.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

class LostAndFoundCard extends StatelessWidget {
  const LostAndFoundCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        context.pushReplacement(
          const LostAndFoundPage(),
        );
      },
      icon: MingCuteIcons.mgc_desk_line,
      name: "失物招领",
    );
  }
}
