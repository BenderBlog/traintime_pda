/*
School card log list.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/controller/school_card_controller.dart';

class SchoolCardWindow extends StatefulWidget {
  const SchoolCardWindow({super.key});

  @override
  State<SchoolCardWindow> createState() => _SchoolCardWindowState();
}

class _SchoolCardWindowState extends State<SchoolCardWindow> {
  @override
  void initState() {
    super.initState();
    Get.put(SchoolCardController()).refreshPaidRecord();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchoolCardController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("校园卡流水信息"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TextButton(
              child: Text(
                  "选择日期：从 ${Jiffy.parseFromDateTime(c.timeRange[0]!).format(pattern: "yyyy-MM-dd")} "
                  "到 ${Jiffy.parseFromDateTime(c.timeRange[1]!).format(pattern: "yyyy-MM-dd")}"),
              onPressed: () async {
                await showCalendarDatePicker2Dialog(
                  context: context,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    calendarType: CalendarDatePicker2Type.range,
                    selectedDayHighlightColor:
                        Theme.of(context).colorScheme.primary,
                  ),
                  dialogSize: const Size(325, 400),
                  value: c.timeRange,
                  borderRadius: BorderRadius.circular(15),
                ).then((value) {
                  if (value?.length == 2) {
                    if (value?[0] != null && value?[1] != null) {
                      c.timeRange = value!;
                      c.refreshPaidRecord();
                    }
                  }
                });
              },
            ),
          ),
        ),
        body: Obx(
          () {
            if (c.getPaid.isNotEmpty) {
              return SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 40.0,
                  columns: const [
                    DataColumn(label: Center(child: Text('商户名称'))),
                    DataColumn(label: Center(child: Text('金额'))),
                    DataColumn(label: Center(child: Text('时间'))),
                  ],
                  rows: [
                    for (var i in c.getPaid)
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text(i.place)),
                          DataCell(Text(i.money)),
                          DataCell(Text(i.date)),
                        ],
                      ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
