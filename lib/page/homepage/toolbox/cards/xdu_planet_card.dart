// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';
import 'package:watermeter/page/xdu_planet/xdu_planet_page.dart';

class XDUPlanetCard extends StatelessWidget {
  const XDUPlanetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const XDUPlanetPage(),
          ),
        );
      },
      icon: MingCuteIcons.mgc_planet_line,
      name: "博客星球",
      description: "学习先辈经验",
    );
  }
}
