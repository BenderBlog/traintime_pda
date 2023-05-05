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
                    size: 16,
                  ),
                  const SizedBox(width: 7.5),
                  Text(
                    "体育信息",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    punchData.value.situation ??
                        "有效次数 ${punchData.value.valid} 所有次数 ${punchData.value.allTime}",
                    textScaleFactor: 1.15,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "最近记录：",
                  textScaleFactor: 1.15,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (punchData.value.all.isNotEmpty)
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.all(7.5),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
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
                                    "${punchData.value.all.last.punchDay}"
                                    " ${punchData.value.all.last.punchTime}",
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
                  )
                else
                  const Center(child: Text("目前没有数据")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
