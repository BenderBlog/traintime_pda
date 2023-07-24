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
import 'package:data_table_2/data_table_2.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';

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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
              )),
        ),
        body: Obx(
          () {
            if (c.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c.error.value),
                    FilledButton.icon(
                      onPressed: () async {
                        await c.relogin();
                        await c.refreshPaidRecord();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("重新加载"),
                    )
                  ],
                ),
              );
            } else if (c.isGet.value) {
              var topRow = const [
                DataColumn(label: Center(child: Text('商户名称'))),
                DataColumn(label: Center(child: Text('金额'))),
                DataColumn(label: Center(child: Text('时间'))),
              ];
              return PaginatedDataTable2(
                columns: topRow,
                source: RecordData(data: c.getPaid),
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

class RecordData extends DataTableSource {
  late List<PaidRecord> data;

  RecordData({required this.data});

  @override
  DataRow? getRow(int index) => DataRow(
        cells: <DataCell>[
          DataCell(Center(child: Text(data[index].place))),
          DataCell(Center(child: Text(data[index].money))),
          DataCell(Center(child: Text(data[index].date))),
        ],
      );

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
