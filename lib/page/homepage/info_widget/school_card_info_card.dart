import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';
import 'package:watermeter/repository/network_session.dart';

class SchoolCardInfoCard extends StatelessWidget {
  final SchoolCardController c = Get.put(SchoolCardController());
  SchoolCardInfoCard({super.key});

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
        child: MainPageCard(
          isLong: false,
          icon: Icons.credit_card,
          text: "校园卡信息",
          children: [
            Expanded(
              child: Center(
                child: Obx(
                  () => Text(
                    "校园卡余额：${c.money.value}",
                    textScaleFactor: 1.15,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
