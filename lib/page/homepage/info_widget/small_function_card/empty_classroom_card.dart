import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/empty_classroom/empty_classroom_window.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';

class EmptyClassroomCard extends StatelessWidget {
  const EmptyClassroomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => GestureDetector(
        onTap: () async {
          if (offline) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("脱机模式下，一站式相关功能全部禁止使用"),
            ));
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EmptyClassroomWindow(),
              ),
            );
          }
        },
        child: const SmallFunctionCard(
          icon: Icons.apartment,
          name: "空闲教室",
          description: "找个地方自习",
        ),
      ),
    );
  }
}
