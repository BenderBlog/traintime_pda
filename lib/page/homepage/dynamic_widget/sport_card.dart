// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/dynamic_widget/main_page_card.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';

class SportCard extends StatelessWidget {
  const SportCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (punchData.value.situation == null && punchData.value.allTime == -1) {
      SportSession().getPunch();
    }
    return Obx(
      () => GestureDetector(
        onTap: () async {
          if (punchData.value.situation == null) {
            showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text("最近打卡记录"),
                children: [
                  SimpleDialogOption(
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Text(
                                  punchData.value.all.last.time
                                      .format(pattern: "yyyy-MM-dd HH:mm:ss"),
                                ).expanded(),
                              ],
                            ),
                            const SizedBox(height: 2.0),
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
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
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
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SportWindow(),
                          ),
                        );
                      },
                      child: const Text("查看详情"),
                    ),
                  ),
                ],
              ),
            );
          } else {
            if (punchData.value.situation == "没有密码") {
              showDialog(
                context: context,
                builder: (context) => const SportPasswordDialog(),
              );
            }
          }
        },
        onLongPress: SportSession().getPunch,
        child: MainPageCard(
          isBold: true,
          icon: MingCuteIcons.mgc_run_fill,
          text: "体育信息",
          isLoad: punchData.value.situation == "正在获取",
          progress: punchData.value.validTime / 50,
          infoText: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 20,
              ),
              children: punchData.value.situation == null
                  ? [
                      TextSpan(
                        text: "${punchData.value.validTime}",
                        style: const TextStyle(
                          fontSize: 28,
                        ),
                      ),
                      const TextSpan(
                        text: " 次",
                      ),
                    ]
                  : [
                      TextSpan(
                        text: "${punchData.value.situation}",
                      ),
                    ],
            ),
          ),
          bottomText: Text(
            punchData.value.situation ?? "总共 ${punchData.value.allTime} 次",
          ),
        ),
      ),
    );
  }
}
