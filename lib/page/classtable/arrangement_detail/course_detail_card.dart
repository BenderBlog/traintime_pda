// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// A dialog/card shows the class detail / time arrangement.
class ClassDetailCard extends StatelessWidget {
  final ClassDetail classDetail;
  final TimeArrangement timeArrangement;
  final MaterialColor infoColor;
  final int currentWeek;
  const ClassDetailCard({
    super.key,
    required this.classDetail,
    required this.timeArrangement,
    required this.infoColor,
    required this.currentWeek,
  });

  /// A doc shows the week info of the class, whether the class /
  /// time arrangement occurs in this week.
  Widget weekDoc({required int index}) {
    bool isOccupied = true;
    if (!timeArrangement.weekList[index]) {
      isOccupied = false;
    }
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? infoColor.shade200 : null,
          borderRadius: const BorderRadius.all(Radius.circular(100.0)),
          border: index == currentWeek
              ? Border.all(width: 2, color: infoColor)
              : null,
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: TextStyle(
              color: isOccupied
                  ? infoColor.shade900
                  : infoColor.shade400.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 360.0,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        elevation: 0,
        color: infoColor.shade100,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            15,
            15,
            15,
            timeArrangement.source == Source.user ? 8 : 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${classDetail.name}"
                "${classDetail.code != null && classDetail.number != null ? "\n${classDetail.code} | ${classDetail.number} 班" : ""}",
                style: TextStyle(
                  color: infoColor.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    child: CustomListTile(
                      icon: Icons.person,
                      str: timeArrangement.teacher ?? "老师未定",
                      infoColor: infoColor,
                    ),
                  ),
                  Flexible(
                    child: CustomListTile(
                      icon: Icons.room,
                      str: timeArrangement.classroom ?? "地点未定",
                      infoColor: infoColor,
                    ),
                  ),
                ],
              ),
              CustomListTile(
                icon: Icons.access_time_filled_outlined,
                str: "${weekList[timeArrangement.day - 1]}"
                    "${timeArrangement.start}-${timeArrangement.stop}节 "
                    "${time[(timeArrangement.start - 1) * 2]}-${time[(timeArrangement.stop - 1) * 2 + 1]}",
                infoColor: infoColor,
              ),

              /// These gridview can show when this arrangment occurs in weeks.
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GridView.extent(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  maxCrossAxisExtent: 30,
                  children: List.generate(
                    timeArrangement.weekList.length,
                    (index) => weekDoc(index: index),
                  ),
                ),
              ),

              if (timeArrangement.source == Source.user)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ClassAddWindow(
                                toChange: (classDetail, timeArrangement),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "编辑",
                          style: TextStyle(
                            color: infoColor.shade900,
                          ),
                        )),
                    TextButton(
                        onPressed: () async {
                          bool? isContinue = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("是否删除课程信息？"),
                              content: const Text(
                                "所有关于这个课的信息都会被删除，课表上关于这门课的信息将不复存在！",
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('确定'),
                                ),
                              ],
                            ),
                          );
                          if (context.mounted && isContinue == true) {
                            await ClassTableState.of(context)!
                                .controllers
                                .deleteUserDefinedClass(timeArrangement)
                                .then((value) {
                              if (context.mounted) Navigator.pop(context);
                            });
                          }
                        },
                        child: Text(
                          "删除",
                          style: TextStyle(
                            color: infoColor.shade900,
                          ),
                        ))
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String str;
  final MaterialColor infoColor;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.str,
    required this.infoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: infoColor.shade900,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            str,
            style: TextStyle(
              color: infoColor.shade900,
              fontSize: 16,
            ),
          ),
        )
      ],
    ).padding(vertical: 4);
  }
}
