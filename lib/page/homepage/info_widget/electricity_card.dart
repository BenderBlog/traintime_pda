import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card.dart';
import 'package:watermeter/repository/electricity_session.dart';

class ElectricityCard extends StatelessWidget {
  const ElectricityCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (electricityInfo.value.isEmpty) {
      update();
    }
    return GestureDetector(
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content:
              Text("电费帐号：${ElectricitySession.electricityAccount()}\n长按可以重新加载"),
        ));
      },
      onLongPress: () async => await update(),
      child: MainPageCard(
        height: 100,
        icon: Icons.electric_meter_rounded,
        text: "电量信息",
        children: [
          Expanded(
            child: Center(
              child: Obx(
                () => Text(
                  electricityInfo.value,
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
    );
  }
}
