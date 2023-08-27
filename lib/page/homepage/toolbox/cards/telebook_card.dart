// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';
import 'package:watermeter/page/telebook/telebook_view.dart';

class TeleBookCard extends StatelessWidget {
  const TeleBookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TeleBookWindow(),
          ),
        );
      },
      icon: Icons.contacts_rounded,
      name: "电话本",
      description: "校园服务电话",
    );
  }
}
