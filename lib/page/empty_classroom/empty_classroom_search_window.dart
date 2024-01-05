// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/jiaowu_service_session.dart';

class EmptyClassroomSearchWindow extends StatefulWidget {
  final List<EmptyClassroomPlace> places;

  const EmptyClassroomSearchWindow({
    super.key,
    required this.places,
  });

  @override
  State<EmptyClassroomSearchWindow> createState() =>
      _EmptyClassroomSearchWindowState();
}

class _EmptyClassroomSearchWindowState
    extends State<EmptyClassroomSearchWindow> {
  final TextEditingController text = TextEditingController();
  List<EmptyClassroomData> fetchedData = [];
  late EmptyClassroomPlace chosen;

  late ColorScheme colorScheme;
  late DateTime time;

  SessionState state = SessionState.none;

  List<EmptyClassroomData> get data {
    List<EmptyClassroomData> toReturn = [];
    for (var i in fetchedData) {
      if (i.name.contains(text.text)) toReturn.add(i);
    }
    return toReturn;
  }

  void updateData() async {
    try {
      state = SessionState.fetching;
      fetchedData.clear();
      fetchedData.addAll(await JiaowuServiceSession().searchEmptyClassroomData(
        buildingCode: chosen.code,
        date: Jiffy.parseFromDateTime(time).format(pattern: "yyyy-MM-dd"),
      ));
      state = SessionState.fetched;
    } catch (e) {
      state = SessionState.error;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    chosen = widget.places.first;
    time = DateTime.now();
    updateData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    colorScheme = Theme.of(context).colorScheme;
    super.didChangeDependencies();
  }

  Widget getIcon(bool isUsed) => Icon(
        Icons.flag,
        color: isUsed ? Colors.red : Colors.transparent,
      ).center();

  void chooseBuilding() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                widget.places.length,
                (index) {
                  return RadioListTile<EmptyClassroomPlace>(
                    title: Text(widget.places[index].name),
                    value: widget.places[index],
                    groupValue: chosen,
                    onChanged: (EmptyClassroomPlace? value) {
                      if (value != null) {
                        setState(() {
                          chosen = value;
                          updateData();
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
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
              ),
              onPressed: () async {
                await showCalendarDatePicker2Dialog(
                  context: context,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    calendarType: CalendarDatePicker2Type.single,
                    selectedDayHighlightColor: colorScheme.primary,
                  ),
                  dialogSize: const Size(325, 400),
                  value: [time],
                  borderRadius: BorderRadius.circular(14),
                ).then((value) {
                  if (value?.length == 1 && value?[0] != null) {
                    setState(() {
                      time = value![0]!;
                      updateData();
                    });
                  }
                });
              },
              child: Text(
                "日期 ${Jiffy.parseFromDateTime(time).format(pattern: "yyyy-MM-dd")}",
              ),
            ).padding(right: 8),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
              ),
              onPressed: () {
                setState(() {
                  text.clear();
                });
                chooseBuilding();
              },
              child: Text(
                "教学楼 ${chosen.name}",
              ),
            ),
            TextField(
              controller: text,
              autofocus: false,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                hintText: "教室名称或者教室代码",
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (String text) => setState(() {}),
            ),
          ],
        ).padding(horizontal: 14, top: 8, bottom: 6).constrained(maxWidth: 480),
        if (state == SessionState.fetching)
          const CircularProgressIndicator().center().expanded()
        else if (state == SessionState.error)
          ReloadWidget(
            function: () => setState(() {
              updateData();
            }),
          ).expanded()
        else
          DataTable2(
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
              data.length,
              (index) => DataRow(
                cells: [
                  DataCell(
                    Center(
                      child: Text(
                        data[index].name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataCell(
                    getIcon(data[index].isUsed1To2),
                  ),
                  DataCell(
                    getIcon(data[index].isUsed3To4),
                  ),
                  DataCell(
                    getIcon(data[index].isUsed5To6),
                  ),
                  DataCell(
                    getIcon(data[index].isUsed7To8),
                  ),
                  DataCell(
                    getIcon(data[index].isUsed9To10),
                  ),
                ],
              ),
            ),
          ).constrained(maxWidth: sheetMaxWidth).center().expanded(),
      ],
    );
  }
}
