// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// School card log list.
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:time/time.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class SchoolCardWindow extends StatefulWidget {
  const SchoolCardWindow({super.key});

  @override
  State<SchoolCardWindow> createState() => _SchoolCardWindowState();
}

class _SchoolCardWindowState extends State<SchoolCardWindow> {
  List<DateTime?> timeRange = [];
  late Future<List<PaidRecord>> getPaid;
  late DateTime now;
  DateFormat formatter = DateFormat("yyyy-MM-dd");

  String moneySunUp(List<PaidRecord> theRecord) {
    double sumUp = 0;
    for (var element in theRecord) {
      sumUp += double.parse(element.money);
    }
    if (sumUp.isLowerThan(0)) {
      return FlutterI18n.translate(
        context,
        "school_card_window.expense",
        translationParams: {"expense": (sumUp * -1).toStringAsFixed(2)},
      );
    } else {
      return FlutterI18n.translate(
        context,
        "school_card_window.income",
        translationParams: {"income": sumUp.toStringAsFixed(2)},
      );
    }
  }

  void refreshPaidStatus() => setState(() {
    getPaid = SchoolCardSession().getPaidStatus(
      formatter.format(timeRange[0]!),
      formatter.format(timeRange[1]!),
    );
  });

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    timeRange = [now.firstDayOfMonth, now];
    refreshPaidStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "school_card_window.title")),
      ),
      body: Column(
        children: [
          FilledButton(
            child: Text(
              FlutterI18n.translate(
                context,
                "school_card_window.select_range",
                translationParams: {
                  "startDay": formatter.format(timeRange[0]!),
                  "endDay": formatter.format(timeRange[1]!),
                },
              ),
            ),
            onPressed: () async {
              await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  calendarType: CalendarDatePicker2Type.range,
                  selectedDayHighlightColor: Theme.of(
                    context,
                  ).colorScheme.primary,
                ),
                dialogSize: const Size(324, 400),
                value: timeRange,
                borderRadius: BorderRadius.circular(16),
              ).then((value) {
                if (value?.length == 1) {
                  timeRange = [value?[0], value?[0]];
                  refreshPaidStatus();
                } else if (value?.length == 2) {
                  timeRange = [value?[0], value?[1]];
                  refreshPaidStatus();
                }
              });
            },
          ).padding(horizontal: 16, vertical: 8),
          FutureBuilder(
            future: getPaid,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return ReloadWidget(
                    errorStatus: snapshot.error,
                    function: () => refreshPaidStatus(),
                  ).center();
                } else if (snapshot.data!.isEmpty) {
                  return EmptyListView(
                    type: EmptyListViewType.singing,
                    text: FlutterI18n.translate(
                      context,
                      "school_card_window.no_record",
                    ),
                  );
                } else {
                  final theme = Theme.of(context);
                  final headerStyle = theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  );
                  final cellStyle = theme.textTheme.bodyMedium;

                  final headerRow = [
                    Text(
                      FlutterI18n.translate(
                        context,
                        "school_card_window.store_name",
                      ),
                      style: headerStyle,
                      textAlign: TextAlign.center,
                    ).expanded(flex: 3),
                    Text(
                      FlutterI18n.translate(
                        context,
                        "school_card_window.balance",
                      ),
                      style: headerStyle,
                      textAlign: TextAlign.center,
                    ).expanded(flex: 2),
                    Text(
                      FlutterI18n.translate(
                        context,
                        "school_card_window.time_with_sum",
                        translationParams: {"sum": moneySunUp(snapshot.data!)},
                      ),
                      style: headerStyle,
                      textAlign: TextAlign.center,
                    ).expanded(flex: 4),
                  ].toRow().padding(vertical: 10);

                  final dataRows = List<Widget>.generate(
                    snapshot.data!.length,
                    (index) {
                      final record = snapshot.data![index];
                      return [
                        if (index != 0)
                          const Divider(
                            height: 1,
                          ).constrained(width: sheetMaxWidth),
                        [
                              Text(
                                record.place,
                                style: cellStyle,
                                textAlign: TextAlign.center,
                              ).expanded(flex: 3),
                              Text(
                                record.money,
                                style: cellStyle,
                                textAlign: TextAlign.center,
                              ).expanded(flex: 2),
                              Text(
                                record.date,
                                style: cellStyle,
                                textAlign: TextAlign.center,
                              ).expanded(flex: 4),
                            ]
                            .toRow()
                            .padding(vertical: 10)
                            .constrained(width: sheetMaxWidth),
                      ].toColumn().width(double.infinity);
                    },
                  );

                  return Column(
                    children: [
                      headerRow.constrained(width: sheetMaxWidth),
                      const Divider(
                        height: 1,
                      ).constrained(width: sheetMaxWidth),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: dataRows),
                        ),
                      ),
                    ],
                  );
                }
              } else {
                return const CircularProgressIndicator().center();
              }
            },
          ).expanded(),
        ],
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
