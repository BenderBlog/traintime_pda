// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_add/wheel_choser.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class ClassAddWindow extends StatefulWidget {
  final (ClassDetail, TimeArrangement)? toChange;
  const ClassAddWindow({super.key, this.toChange});

  @override
  State<ClassAddWindow> createState() => _ClassAddWindowState();
}

class _ClassAddWindowState extends State<ClassAddWindow> {
  late final ClassTableWidgetState controller;
  late List<bool> chosenWeek;
  late TextEditingController classNameController;
  late TextEditingController teacherNameController;
  late TextEditingController classRoomController;

  late int week;
  late int start;
  late int stop;

  final double inputFieldVerticalPadding = 4;
  final double horizontalPadding = 10;

  Color get color => Theme.of(context).colorScheme.primary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ClassTableState.of(context)!.controllers;
    if (widget.toChange == null) {
      classNameController = TextEditingController();
      teacherNameController = TextEditingController();
      classRoomController = TextEditingController();
      chosenWeek = List<bool>.generate(
        controller.semesterLength,
        (index) => false,
      );
      week = 1;
      start = 1;
      stop = 1;
    } else {
      classNameController = TextEditingController(
        text: widget.toChange!.$1.name,
      );
      teacherNameController = TextEditingController(
        text: widget.toChange!.$2.teacher,
      );
      classRoomController = TextEditingController(
        text: widget.toChange!.$2.classroom,
      );
      chosenWeek = widget.toChange!.$2.weekList;
      week = widget.toChange!.$2.day;
      start = widget.toChange!.$2.start;
      stop = widget.toChange!.$2.stop;
    }
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
        title: Text(widget.toChange == null
            ? FlutterI18n.translate(
                context,
                "classtable.class_add.add_class_title",
              )
            : FlutterI18n.translate(
                context,
                "classtable.class_add.change_class_title",
              )),
        actions: [
          TextButton(
            onPressed: () async {
              if (classNameController.text.isEmpty) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "classtable.class_add.class_name_empty_message",
                  ),
                );
              } else if (!(week > 0 && week <= 7) || !(start <= stop)) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "classtable.class_add.wrong_time_message",
                  ),
                );
              } else if (widget.toChange == null) {
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
                    .then((value) {
                  if (context.mounted) Navigator.of(context).pop();
                });
              } else {
                await controller
                    .editUserDefinedClass(
                        widget.toChange!.$2,
                        ClassDetail(name: classNameController.text),
                        TimeArrangement(
                          source: Source.user,
                          index: widget.toChange!.$2.index,
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
                    .then((value) {
                  if (context.mounted) Navigator.of(context).pop();
                });
              }
            },
            child: Text(FlutterI18n.translate(
              context,
              "classtable.class_add.save_button",
            )),
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
                  hintText: FlutterI18n.translate(
                    context,
                    "classtable.class_add.input_classname_hint",
                  ),
                ),
              ).padding(vertical: inputFieldVerticalPadding),
              TextField(
                controller: teacherNameController,
                decoration: inputDecoration.copyWith(
                  icon: Icon(
                    Icons.person,
                    color: color,
                  ),
                  hintText: FlutterI18n.translate(
                    context,
                    "classtable.class_add.input_teacher_hint",
                  ),
                ),
              ).padding(vertical: inputFieldVerticalPadding),
              TextField(
                controller: classRoomController,
                decoration: inputDecoration.copyWith(
                  icon: Icon(
                    Icons.place,
                    color: color,
                  ),
                  hintText: FlutterI18n.translate(
                    context,
                    "classtable.class_add.input_classroom_hint",
                  ),
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
                  Text(FlutterI18n.translate(
                    context,
                    "classtable.class_add.input_week_hint",
                  )).textStyle(TextStyle(color: color)).padding(left: 4),
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
                  Text(FlutterI18n.translate(
                    context,
                    "classtable.class_add.input_time_hint",
                  )).textStyle(TextStyle(color: color)).padding(left: 4),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      Text(FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_time_weekday_hint",
                      )).textStyle(TextStyle(color: color)).center().flexible(),
                      Text(FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_start_time_hint",
                      )).textStyle(TextStyle(color: color)).center().flexible(),
                      Text(FlutterI18n.translate(
                        context,
                        "classtable.class_add.input_end_time_hint",
                      )).textStyle(TextStyle(color: color)).center().flexible(),
                    ],
                  ),
                  Row(
                    children: [
                      WheelChoose(
                        changeBookIdCallBack: (choiceWeek) {
                          setState(() {
                            week = choiceWeek + 1;
                          });
                        },
                        defaultPage: week - 1,
                        options: List.generate(
                          7,
                          (index) => WheelChooseOptions(
                            data: index,
                            hint: getWeekString(context, index),
                          ),
                        ),
                      ).flexible(),
                      WheelChoose(
                        changeBookIdCallBack: (choiceWeek) {
                          setState(() {
                            start = choiceWeek;
                          });
                        },
                        defaultPage: start - 1,
                        options: List.generate(
                          10,
                          (index) => WheelChooseOptions(
                            data: index + 1,
                            hint: FlutterI18n.translate(
                              context,
                              "classtable.class_add.wheel_choose_hint",
                              translationParams: {
                                "index": (index + 1).toString(),
                              },
                            ),
                          ),
                        ),
                      ).flexible(),
                      WheelChoose(
                        changeBookIdCallBack: (choiceStop) {
                          setState(() {
                            stop = choiceStop;
                          });
                        },
                        defaultPage: stop - 1,
                        options: List.generate(
                          10,
                          (index) => WheelChooseOptions(
                            data: index + 1,
                            hint: FlutterI18n.translate(
                              context,
                              "classtable.class_add.wheel_choose_hint",
                              translationParams: {
                                "index": (index + 1).toString()
                              },
                            ),
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
