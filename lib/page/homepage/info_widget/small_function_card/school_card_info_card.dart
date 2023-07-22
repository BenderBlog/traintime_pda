import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';
import 'package:watermeter/repository/network_session.dart';

class SchoolCardInfoCard extends StatelessWidget {
  const SchoolCardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchoolCardController>(
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
                builder: (context) => const SchoolCardWindow(),
              ),
            );
          }
        },
        onLongPress: () {
          if (offline) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("脱机模式下，一站式相关功能全部禁止使用"),
            ));
          } else {
            c.updateMoney();
          }
        },
        child: const SmallFunctionCard(
          icon: Icons.currency_yuan,
          name: "流水查询",
          description: "食堂哪个好吃",
        ),
      ),
    );
  }
}
