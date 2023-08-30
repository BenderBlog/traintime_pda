// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';
import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/repository/network_session.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScoreController>(
      builder: (c) => SmallFunctionCard(
        onTap: () {
          if (offline) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("脱机模式下，一站式相关功能全部禁止使用"),
            ));
          } else if (c.error == null) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ScoreWindow()));
          } else if (c.error == "正在加载") {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                "请稍候 正在获取成绩信息",
              ),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("遇到错误，${c.error}"),
            ));
          }
        },
        onLongPress: () {
          if (c.isGet) {
            c.get();
          }
        },
        icon: Icons.grading_rounded,
        name: "成绩查询",
        description: "可计算平均分",
      ),
    );
  }
}
