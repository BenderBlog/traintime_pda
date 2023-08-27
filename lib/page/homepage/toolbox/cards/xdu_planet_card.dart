// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
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
      icon: Icons.rss_feed,
      name: "博客星球",
      description: "学习先辈经验",
    );
  }
}
