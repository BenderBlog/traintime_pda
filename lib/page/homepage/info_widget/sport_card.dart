import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card.dart';
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
        child: MainPageCard(
          icon: Icons.run_circle,
          text: "体育信息",
          height: punchData.value.all.isNotEmpty ? 200 : 100,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  punchData.value.situation ??
                      "有效次数 ${punchData.value.valid} 总共次数 ${punchData.value.allTime} 成绩 ${punchData.value.score}",
                  textScaleFactor: 1.15,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            if (punchData.value.all.isNotEmpty)
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.punch_clock,
                            size: 20,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              punchData.value.all.last.time
                                  .format(pattern: "yyyy-MM-dd HH:mm:ss"),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 20,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              punchData.value.all.last.machineName,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.error_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              punchData.value.all.last.state,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
