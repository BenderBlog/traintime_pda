import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/exam/exam.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/repository/network_session.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (c) => GestureDetector(
        onTap: () async {
          if (offline) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("脱机模式下，一站式相关功能全部禁止使用"),
            ));
          } else if (c.isGet == true) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ExamInfoWindow()));
          } else if (c.error == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                "请稍候 正在获取考试信息",
              ),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("遇到错误：${c.error!}"),
            ));
          }
        },
        child: const SmallFunctionCard(
          icon: Icons.view_timeline_outlined,
          name: "考试查询",
          description: "上天保佑时间",
        ),
      ),
    );
  }
}
