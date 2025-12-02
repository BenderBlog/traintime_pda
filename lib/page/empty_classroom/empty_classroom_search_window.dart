// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/empty_classroom_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class EmptyClassroomSearchWindow extends StatefulWidget {
  final List<EmptyClassroomPlace> places;

  const EmptyClassroomSearchWindow({super.key, required this.places});

  @override
  State<EmptyClassroomSearchWindow> createState() =>
      _EmptyClassroomSearchWindowState();
}

/// Dialog for building selection with auto-scroll to selected item
class _BuildingSelectionDialog extends StatefulWidget {
  final List<EmptyClassroomPlace> places;
  final EmptyClassroomPlace chosen;
  final ValueChanged<EmptyClassroomPlace> onChanged;

  const _BuildingSelectionDialog({
    required this.places,
    required this.chosen,
    required this.onChanged,
  });

  @override
  State<_BuildingSelectionDialog> createState() =>
      _BuildingSelectionDialogState();
}

class _BuildingSelectionDialogState extends State<_BuildingSelectionDialog> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Scroll to selected item after the dialog is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItem();
    });
  }

  void _scrollToSelectedItem() {
    // Find the index of the selected item
    final selectedIndex = widget.places.indexWhere(
      (place) => place.code == widget.chosen.code,
    );
    
    if (selectedIndex == -1 || !_scrollController.hasClients) return;

    // Estimate item height (RadioListTile typically ~56dp)
    const double estimatedItemHeight = 56.0;
    final double targetOffset = selectedIndex * estimatedItemHeight;
    
    // Get the viewport height
    final double viewportHeight = _scrollController.position.viewportDimension;
    
    // Calculate offset to center the selected item
    // Try to position the selected item in the middle of the viewport
    double scrollOffset = targetOffset - (viewportHeight / 2) + (estimatedItemHeight / 2);
    
    // Clamp the offset to valid scroll range
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final double minScrollExtent = _scrollController.position.minScrollExtent;
    scrollOffset = scrollOffset.clamp(minScrollExtent, maxScrollExtent);
    
    // Animate to the calculated position with a bouncy curve
    _scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: RadioGroup<EmptyClassroomPlace>(
          groupValue: widget.chosen,
          onChanged: (EmptyClassroomPlace? value) {
            if (value != null) {
              widget.onChanged(value);
              Navigator.pop(context);
            }
          },
          child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: widget.places.length,
            itemBuilder: (context, index) {
              return RadioListTile<EmptyClassroomPlace>(
                title: Text(widget.places[index].name),
                value: widget.places[index],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyClassroomSearchWindowState
    extends State<EmptyClassroomSearchWindow> {
  final TextEditingController text = TextEditingController();
  List<EmptyClassroomData> fetchedData = [];
  late EmptyClassroomPlace chosen;

  late ColorScheme colorScheme;
  late DateTime time;

  SessionState state = SessionState.none;
  String semesterCode = preference.getString(
    preference.Preference.currentSemester,
  );

  DateFormat formatter = DateFormat("yyyy-MM-dd");

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
      fetchedData.addAll(
        await EmptyClassroomSession().searchData(
          buildingCode: chosen.code,
          date: formatter.format(time),
          semesterRange: "$startYear-${startYear + 1}",
          semesterPart: semesterCode[semesterCode.length - 1],
        ),
      );
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
    String lastChosenClassroom = preference.getString(
      preference.Preference.emptyClassroomLastChoice,
    );
    EmptyClassroomPlace? toGet;
    if (lastChosenClassroom.isNotEmpty) {
      for (var i in widget.places) {
        if (i.code == lastChosenClassroom) toGet = i;
      }
    }
    toGet ??= widget.places.first;
    chosen = toGet;
    time = DateTime.now();
    updateData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    colorScheme = Theme.of(context).colorScheme;
    super.didChangeDependencies();
  }

  Widget getIcon(bool isUsed, {int? index}) =>
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isUsed
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: index != null
            ? Text(
                index.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isUsed
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
              ).center()
            : null,
      ).decorated(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(6),
      );

  void chooseBuilding() => showDialog(
    context: context,
    builder: (context) => _BuildingSelectionDialog(
      places: widget.places,
      chosen: chosen,
      onChanged: (EmptyClassroomPlace value) {
        setState(() {
          chosen = value;
          preference.setString(
            preference.Preference.emptyClassroomLastChoice,
            chosen.code,
          );
          updateData();
        });
      },
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
                      FilledButton(
                        onPressed: () async {
                          await showCalendarDatePicker2Dialog(
                            context: context,
                            config: CalendarDatePicker2WithActionButtonsConfig(
                              calendarType: CalendarDatePicker2Type.single,
                            ),
                            dialogSize: const Size(325, 400),
                            value: [time],
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
                          FlutterI18n.translate(
                            context,
                            "empty_classroom.date",
                            translationParams: {"date": formatter.format(time)},
                          ),
                        ),
                      ).padding(right: 8),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            text.clear();
                          });
                          chooseBuilding();
                        },
                        child: Text(
                          FlutterI18n.translate(
                            context,
                            "empty_classroom.building",
                            translationParams: {"building": chosen.name},
                          ),
                        ),
                      ),
                    ].toRow(),
                  ]
                  .toRow(mainAxisAlignment: MainAxisAlignment.center)
                  .padding(bottom: 8),
              [
                [
                  getIcon(true),
                  const SizedBox(width: 4.0),
                  Text(
                    FlutterI18n.translate(context, "empty_classroom.occupied"),
                  ),
                ].toRow().padding(right: 8.0),
                [
                  getIcon(false),
                  const SizedBox(width: 4.0),
                  Text(FlutterI18n.translate(context, "empty_classroom.empty")),
                ].toRow(),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
            ]
            .toColumn()
            .padding(horizontal: 14, top: 8, bottom: 12)
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
          ListView.separated(
            itemCount: data.length,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            itemBuilder: (context, index) {
              final item = data[index];
              return Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ).center(),
                  ),
                  Flexible(
                    flex: 4,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4.0,
                      children: List.generate(
                        4,
                        (i) => getIcon(item.isUsed[i], index: i + 1),
                      ),
                    ).center(),
                  ),
                  Flexible(
                    flex: 4,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4.0,
                      children: List.generate(
                        4,
                        (i) => getIcon(item.isUsed[i + 4], index: i + 5),
                      ),
                    ).center(),
                  ),
                  Flexible(
                    flex: 3,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4.0,
                      children: List.generate(
                        3,
                        (i) => getIcon(item.isUsed[i + 8], index: i + 9),
                      ),
                    ).center(),
                  ),
                ],
              ).constrained(maxWidth: sheetMaxWidth).center();
            },
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 12),
          ).expanded(),
      ],
    );
  }
}
