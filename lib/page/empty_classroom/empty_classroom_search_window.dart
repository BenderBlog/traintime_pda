// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/empty_classroom_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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
  String semesterCode =
      preference.getString(preference.Preference.currentSemester);

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
      int startYear = int.parse(semesterCode.substring(0, 4));
      fetchedData.addAll(await EmptyClassroomSession().searchData(
        buildingCode: chosen.code,
        date: Jiffy.parseFromDateTime(time).format(pattern: "yyyy-MM-dd"),
        semesterRange: "$startYear-${startYear + 1}",
        semesterPart: semesterCode[semesterCode.length - 1],
      ));
      state = SessionState.fetched;
    } catch (e, s) {
      state = SessionState.error;
      log.error("Error occured while fetching empty classroom.", e, s);
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

  Widget getIcon(bool isUsed, {int? index}) => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isUsed
              ? Colors.transparent
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: index != null
            ? Text(
                index.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUsed
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onPrimary,
                ),
              ).center()
            : null,
      ).decorated(
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(6),
      );

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
        [
          TextField(
            controller: text,
            autofocus: false,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: FlutterI18n.translate(
                context,
                "empty_classroom.search_hint",
              ),
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onSubmitted: (String text) => setState(() {}),
          ).padding(bottom: 8),
          [
            [
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
                child: Text(FlutterI18n.translate(
                  context,
                  "empty_classroom.date",
                  translationParams: {
                    "date": Jiffy.parseFromDateTime(time)
                        .format(pattern: "yyyy-MM-dd")
                  },
                )),
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
                child: Text(FlutterI18n.translate(
                  context,
                  "empty_classroom.building",
                  translationParams: {"building": chosen.name},
                )),
              ),
            ].toRow(),
          ]
              .toRow(mainAxisAlignment: MainAxisAlignment.center)
              .padding(bottom: 8),
          [
            [
              getIcon(true),
              const SizedBox(width: 4.0),
              Text(FlutterI18n.translate(
                context,
                "empty_classroom.occupied",
              )),
            ].toRow().padding(right: 8.0),
            [
              getIcon(false),
              const SizedBox(width: 4.0),
              Text(FlutterI18n.translate(
                context,
                "empty_classroom.empty",
              )),
            ].toRow(),
          ].toRow(mainAxisAlignment: MainAxisAlignment.center),
        ]
            .toColumn()
            .padding(horizontal: 14, top: 8, bottom: 6)
            .constrained(maxWidth: 480),
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
            dividerThickness: 0,
            columnSpacing: 0,
            horizontalMargin: 6,
            headingRowHeight: 0,
            columns: [
              DataColumn2(
                label: Text(FlutterI18n.translate(
                  context,
                  "empty_classroom.classroom",
                )).center(),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: const Text('1-4').center(),
                size: ColumnSize.M,
              ),
              DataColumn2(
                label: const Text('5-8').center(),
                size: ColumnSize.M,
              ),
              DataColumn2(
                label: const Text('9-10').center(),
                size: ColumnSize.S,
              ),
            ],
            rows: List<DataRow>.generate(
              data.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text(
                    data[index].name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ).center()),
                  DataCell(Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4.0,
                    children: List.generate(
                      4,
                      (i) => getIcon(data[index].isUsed[i], index: i + 1),
                    ),
                  ).center()),
                  DataCell(Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4.0,
                    children: List.generate(
                      4,
                      (i) => getIcon(data[index].isUsed[i + 4], index: i + 5),
                    ),
                  ).center()),
                  DataCell(Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4.0,
                    children: List.generate(
                      2,
                      (i) => getIcon(data[index].isUsed[i + 8], index: i + 9),
                    ),
                  ).center()),
                ],
              ),
            ),
          ).constrained(maxWidth: sheetMaxWidth).center().safeArea().expanded(),
      ],
    );
  }
}
