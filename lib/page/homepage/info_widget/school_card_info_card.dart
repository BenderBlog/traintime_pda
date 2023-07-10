import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';

class SchoolCardInfoCard extends StatelessWidget {
  const SchoolCardInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    SchoolCardSession().initSession();
    return GestureDetector(
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("校园卡余额：${money.value}"),
        ));
      },
      onLongPress: () {
        SchoolCardSession().getMoney();
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
                  "校园卡钱财：${money.value}",
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
