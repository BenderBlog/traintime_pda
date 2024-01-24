// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_add/wheel_choser.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class ClassAddWindow extends StatefulWidget {
  const ClassAddWindow({super.key});

  @override
  State<ClassAddWindow> createState() => _ClassAddWindowState();
}

class _ClassAddWindowState extends State<ClassAddWindow> {
  late final ClassTableWidgetState controller;
  late List<bool> chosenWeek;
  TextEditingController classNameController = TextEditingController();
  TextEditingController teacherNameController = TextEditingController();
  TextEditingController classRoomController = TextEditingController();

  int week = 1;
  int start = 1;
  int stop = 1;

  final double inputFieldVerticalPadding = 4;
  final double horizontalPadding = 10;

  Color get color => Theme.of(context).colorScheme.primary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller = ClassTableState.of(context)!.controllers;
    chosenWeek = List<bool>.generate(
      controller.semesterLength,
      (index) => false,
    );
  }

  InputDecoration get inputDecoration => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      );

  Widget weekDoc({required int index}) {
    return Text((index + 1).toString())
        .textColor(color)
        .center()
        .decorated(
          color: chosenWeek[index] ? color.withOpacity(0.2) : null,
          borderRadius: const BorderRadius.all(Radius.circular(100.0)),
        )
        .clipOval()
        .gestures(
          onTap: () => setState(() => chosenWeek[index] = !chosenWeek[index]),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加课程"),
        actions: [
          TextButton(
            onPressed: () async {
              if (classNameController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: "必须输入课程名",
                );
              } else if ((week > 0 && week <= 7) && (start <= stop)) {
                await controller
                    .addUserDefinedClass(
                        ClassDetail(name: classNameController.text),
                        TimeArrangement(
                          source: Source.user,
                          index: -1,
                          teacher: teacherNameController.text.isNotEmpty
                              ? teacherNameController.text
                              : null,
                          classroom: classRoomController.text.isNotEmpty
                              ? classRoomController.text
                              : null,
                          weekList: chosenWeek,
                          day: week,
                          start: start,
                          stop: stop,
                        ))
                    .then(
                      (value) => Navigator.of(context).pop(),
                    );
              } else {
                Fluttertoast.showToast(
                  msg: "输入的时间不对",
                );
              }
            },
            child: const Text("保存"),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        children: [
          Column(
            children: [
              TextField(
                controller: classNameController,
                decoration: inputDecoration.copyWith(
                  icon: Icon(
                    Icons.calendar_month,
                    color: color,
                  ),
                  hintText: "课程名字(必填)",
                ),
              ).padding(vertical: inputFieldVerticalPadding),
              TextField(
                controller: teacherNameController,
                decoration: inputDecoration.copyWith(
                  icon: Icon(
                    Icons.person,
                    color: color,
                  ),
                  hintText: "老师姓名(选填)",
                ),
              ).padding(vertical: inputFieldVerticalPadding),
              TextField(
                controller: classRoomController,
                decoration: inputDecoration.copyWith(
                  icon: Icon(
                    Icons.place,
                    color: color,
                  ),
                  hintText: "教室位置(选填)",
                ),
              ).padding(vertical: inputFieldVerticalPadding),
            ],
          )
              .padding(
                vertical: 8,
                horizontal: 16,
              )
              .card(
                margin: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                elevation: 0,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: color,
                    size: 16,
                  ),
                  const Text("选择上课周次")
                      .textStyle(TextStyle(color: color))
                      .padding(left: 4),
                ],
              ),
              const SizedBox(height: 8),
              GridView.extent(
                padding: EdgeInsets.zero,
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                maxCrossAxisExtent: 30,
                children: List.generate(
                  controller.semesterLength,
                  (index) => weekDoc(index: index),
                ),
              ),
            ],
          ).padding(all: 12).card(
                margin: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                elevation: 0,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: color,
                    size: 16,
                  ),
                  const Text("选择上课时间")
                      .textStyle(TextStyle(color: color))
                      .padding(left: 4),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      const Text("上课周次")
                          .textStyle(TextStyle(color: color))
                          .center()
                          .flexible(),
                      const Text("上课时间段")
                          .textStyle(TextStyle(color: color))
                          .center()
                          .flexible(),
                      const Text("下课时间段")
                          .textStyle(TextStyle(color: color))
                          .center()
                          .flexible(),
                    ],
                  ),
                  Row(
                    children: [
                      PageChoose(
                        changeBookIdCallBack: (choiceWeek) {
                          setState(() {
                            week = choiceWeek + 1;
                          });
                        },
                        options: List.generate(
                          weekList.length,
                          (index) => PageChooseOptions(
                            data: index,
                            hint: weekList[index],
                          ),
                        ),
                      ).flexible(),
                      PageChoose(
                        changeBookIdCallBack: (choiceWeek) {
                          setState(() {
                            start = choiceWeek;
                          });
                        },
                        options: List.generate(
                          10,
                          (index) => PageChooseOptions(
                            data: index + 1,
                            hint: "第 ${index + 1} 节",
                          ),
                        ),
                      ).flexible(),
                      PageChoose(
                        changeBookIdCallBack: (choiceStop) {
                          setState(() {
                            stop = choiceStop;
                          });
                        },
                        options: List.generate(
                          10,
                          (index) => PageChooseOptions(
                            data: index + 1,
                            hint: "第 ${index + 1} 节",
                          ),
                        ),
                      ).flexible()
                    ],
                  ),
                ],
              ),
            ],
          ).padding(all: 12).card(
                margin: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                elevation: 0,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
        ],
      ),
    );
  }
}
