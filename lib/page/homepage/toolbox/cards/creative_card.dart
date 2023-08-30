// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/creative_job/creative_job.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';

class CreativeCard extends StatelessWidget {
  const CreativeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreativeJobView(),
          ),
        );
      },
      icon: MingCuteIcons.mgc_star_line,
      name: "双创竞赛",
      description: "拉队友来看看",
    );
  }
}
