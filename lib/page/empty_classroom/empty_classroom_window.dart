// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/controller/empty_classroom_controller.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class EmptyClassroomWindow extends StatefulWidget {
  const EmptyClassroomWindow({super.key});

  @override
  State<EmptyClassroomWindow> createState() => _EmptyClassroomWindowState();
}

class _EmptyClassroomWindowState extends State<EmptyClassroomWindow> {
  final TextEditingController text = TextEditingController();
  late EmptyClassroomController c;

  @override
  void initState() {
    c = Get.put(EmptyClassroomController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<EmptyClassroomController>();
    super.dispose();
  }

  Widget getIcon(bool isUsed) => Center(
        child: Icon(
          Icons.flag,
          color: isUsed ? Colors.red : Colors.transparent,
        ),
      );

  void chooseBuilding() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                c.places.length,
                (index) {
                  return RadioListTile<EmptyClassroomPlace>(
                    title: Text(c.places[index].name),
                    value: c.places[index],
                    groupValue: c.chosen.value,
                    onChanged: (EmptyClassroomPlace? value) {
                      if (value != null) {
                        setState(() {
                          c.chosen.value = value;
                        });
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    text.text = c.searchParameter.value;
    var colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => Scaffold(
          appBar: AppBar(title: const Text("空闲教室")),
          body: Column(
            children: [
              if (c.places.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: colorScheme.secondaryContainer,
                            ),
                            onPressed: () async {
                              await showCalendarDatePicker2Dialog(
                                context: context,
                                config:
                                    CalendarDatePicker2WithActionButtonsConfig(
                                  calendarType: CalendarDatePicker2Type.single,
                                  selectedDayHighlightColor:
                                      colorScheme.primary,
                                ),
                                dialogSize: const Size(325, 400),
                                value: [c.time.value],
                                borderRadius: BorderRadius.circular(15),
                              ).then((value) {
                                if (value?.length == 1 && value?[0] != null) {
                                  setState(() {
                                    c.time.value = value![0]!;
                                  });
                                }
                              });
                            },
                            child: Text(
                              "日期 ${Jiffy.parseFromDateTime(c.time.value).format(pattern: "yyyy-MM-dd")}",
                            ),
                          ),
                          const VerticalDivider(
                            color: Colors.transparent,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: colorScheme.secondaryContainer,
                            ),
                            onPressed: () => chooseBuilding(),
                            child: Text(
                              "教学楼 ${c.chosen.value.name}",
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: text,
                          autofocus: false,
                          decoration: InputDecoration(
                            isDense: true,
                            fillColor: Colors.grey.withOpacity(0.2),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            hintText: "教室名称或者教室代码",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (String text) {
                            c.searchParameter.value = text;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              if (!c.isLoad.value && !c.isError.value)
                Expanded(
                  child: c.isLoad.value
                      ? const Center(child: CircularProgressIndicator())
                      : c.isError.value
                          ? ReloadWidget(
                              function: () => c.updateData(),
                            )
                          : Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: sheetMaxWidth),
                                child: DataTable2(
                                  columnSpacing: 0,
                                  horizontalMargin: 6,
                                  columns: const [
                                    DataColumn2(
                                      label: Center(child: Text('教室')),
                                      size: ColumnSize.L,
                                    ),
                                    DataColumn2(
                                      label: Center(child: Text('1-2')),
                                      size: ColumnSize.S,
                                    ),
                                    DataColumn2(
                                      label: Center(child: Text('3-4')),
                                      size: ColumnSize.S,
                                    ),
                                    DataColumn2(
                                      label: Center(child: Text('5-6')),
                                      size: ColumnSize.S,
                                    ),
                                    DataColumn2(
                                      label: Center(child: Text('7-8')),
                                      size: ColumnSize.S,
                                    ),
                                    DataColumn2(
                                      label: Center(child: Text('9-10')),
                                      size: ColumnSize.S,
                                    ),
                                  ],
                                  rows: List<DataRow>.generate(
                                    c.data.length,
                                    (index) => DataRow(
                                      cells: [
                                        DataCell(
                                          Center(
                                            child: Text(
                                              c.data[index].name,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          getIcon(c.data[index].isUsed1To2),
                                        ),
                                        DataCell(
                                          getIcon(c.data[index].isUsed3To4),
                                        ),
                                        DataCell(
                                          getIcon(c.data[index].isUsed5To6),
                                        ),
                                        DataCell(
                                          getIcon(c.data[index].isUsed7To8),
                                        ),
                                        DataCell(
                                          getIcon(c.data[index].isUsed9To10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
            ],
          )),
    );
  }
}
