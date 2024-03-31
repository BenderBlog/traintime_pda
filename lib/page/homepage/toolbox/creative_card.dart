// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/creative_job/creative_job.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class CreativeCard extends StatelessWidget {
  const CreativeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        if (offline) {
          Fluttertoast.showToast(msg: "脱机模式下，一站式相关功能全部禁止使用");
        } else {
          context.push(
            const CreativeJobView(),
          );
        }
      },
      icon: MingCuteIcons.mgc_star_line,
      name: "双创竞赛",
    );
  }
}
