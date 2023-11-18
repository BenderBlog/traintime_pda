// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/empty_classroom/empty_classroom_window.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';

class EmptyClassroomCard extends StatelessWidget {
  const EmptyClassroomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => SmallFunctionCard(
        onTap: () async {
          if (offline) {
            Fluttertoast.showToast(msg: "脱机模式下，一站式相关功能全部禁止使用");
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EmptyClassroomWindow(),
              ),
            );
          }
        },
        icon: MingCuteIcons.mgc_building_2_line,
        name: "空闲教室",
        description: "找个地方自习",
      ),
    );
  }
}
