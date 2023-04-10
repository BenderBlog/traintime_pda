import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/repository/xidian_sport/punch_session.dart';
import 'package:watermeter/page/setting/subwindow/sport_password_dialog.dart';

class SportCard extends StatelessWidget {
  const SportCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (punchData.value.situation == null && punchData.value.allTime == -1) {
      getPunch();
    }
    return Obx(
      () => GestureDetector(
        onTap: () async {
          if (punchData.value.situation == null) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SportWindow()));
          } else {
            if (punchData.value.situation == "无密码信息") {
              showDialog(
                context: context,
                builder: (context) => const SportPasswordDialog(),
              );
            }
          }
        },
        onLongPress: getPunch,
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(
                    Icons.run_circle,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 14,
                  ),
                  const SizedBox(width: 7.5),
                  Text(
                    "体育信息",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ]),
                const SizedBox(width: 15),
                Expanded(
                  child: Center(
                    child: Text(
                      punchData.value.situation ??
                          "有效次数 ${punchData.value.valid}\n所有次数 ${punchData.value.allTime}",
                      textScaleFactor: 1.15,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
