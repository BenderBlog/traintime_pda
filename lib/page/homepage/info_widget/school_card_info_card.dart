import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';

class SchoolCardInfoCard extends StatelessWidget {
  final SchoolCardController c = Get.put(SchoolCardController());
  SchoolCardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchoolCardController>(
      builder: (c) => GestureDetector(
        onTap: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SchoolCardWindow(),
            ),
          );
        },
        onLongPress: () {
          c.updateMoney();
        },
        child: MainPageCard(
          height: 100,
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
