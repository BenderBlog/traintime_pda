// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';
import 'package:watermeter/page/public_widget/split_view.dart';
import 'package:watermeter/page/toolbox/toolbox_page.dart';

class ToolboxCard extends StatelessWidget {
  const ToolboxCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        SplitView.of(context).setSecondary(
          const ToolBoxPage(),
        );
      },
      icon: MingCuteIcons.mgc_tool_line,
      name: "其他功能",
    );
  }
}
