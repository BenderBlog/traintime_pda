// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// School card log list.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/page/widget.dart';

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

  String moneySunUp(List<PaidRecord> theRecord) {
    double sumUp = 0;
    for (var element in theRecord) {
      sumUp += double.parse(element.money);
    }
    if (sumUp.isLowerThan(0)) {
      return "支出 ${(sumUp * -1).toStringAsFixed(2)}";
    } else {
      return "收入 ${sumUp.toStringAsFixed(2)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchoolCardController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("校园卡流水信息"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
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
                    dialogSize: const Size(324, 400),
                    value: c.timeRange,
                    borderRadius: BorderRadius.circular(16),
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
        ),
        body: Obx(
          () {
            if (c.isGetRecord.value) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
                  child: DataTable2(
                    columnSpacing: 0,
                    horizontalMargin: 6,
                    columns: [
                      const DataColumn2(
                        size: ColumnSize.S,
                        label: Center(
                          child: Text('商户名称'),
                        ),
                      ),
                      const DataColumn2(
                        size: ColumnSize.S,
                        label: Center(
                          child: Text('金额'),
                        ),
                      ),
                      DataColumn2(
                        size: ColumnSize.L,
                        label: Center(
                          child: Text('时间(共${moneySunUp(c.getPaid)} 元)'),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      c.getPaid.length,
                      (index) => DataRow(
                        cells: [
                          DataCell(
                            Center(
                              child: Text(
                                c.getPaid[index].place,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataCell(Center(child: Text(c.getPaid[index].money))),
                          DataCell(Center(child: Text(c.getPaid[index].date))),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (c.errorRecord.value.isNotEmpty) {
              return ReloadWidget(
                function: () async {
                  await c.relogin();
                  await c.refreshPaidRecord();
                },
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
