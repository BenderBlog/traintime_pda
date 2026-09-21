// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/session_state.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/safe_scroll_padding.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/ids_session/empty_classroom_session.dart';
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
    double scrollOffset =
        targetOffset - (viewportHeight / 2) + (estimatedItemHeight / 2);

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

  /// 只看现在这一刻还空着的教室。
  bool onlyFreeNow = false;

  /// 「现在」这个说法要跟着时间走，所以页面开着的时候每分钟重算一次。
  Timer? clock;

  /// The classrooms which are shown: the ones the search box matches, and the
  /// ones which are free right now when that switch is on.
  List<EmptyClassroomData> get data {
    final period = onlyFreeNow ? nowPeriod : null;
    List<EmptyClassroomData> toReturn = [];
    for (var i in fetchedData) {
      if (!i.name.contains(text.text)) continue;
      if (period != null && i.isUsed[period - 1]) continue;
      toReturn.add(i);
    }
    return toReturn;
  }

  /// Whether the day which is chosen is the day which is going on.
  bool get isToday {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  /// The period which is going on right now, or the one which starts next while
  /// the classes are between two of them.
  ///
  /// It is null when another day is shown - the usage of that day says nothing
  /// about now - and when the last period of the day is over.
  int? get nowPeriod {
    if (!isToday) {
      return null;
    }

    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    for (var index = 0; index < timeList.length ~/ 2; index++) {
      if (minutes <= minutesOf(timeList[index * 2 + 1])) {
        return index + 1;
      }
    }
    return null;
  }

  /// Whether that period has already begun; when it has not, the classes are on
  /// a break and the period which is shown is the one which comes next.
  bool get isNowOngoing {
    final period = nowPeriod;
    if (period == null) {
      return false;
    }

    final now = DateTime.now();
    return now.hour * 60 + now.minute >= minutesOf(timeList[(period - 1) * 2]);
  }

  int minutesOf(String hourMinute) {
    final parts = hourMinute.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
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
    clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    clock?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    colorScheme = Theme.of(context).colorScheme;
    super.didChangeDependencies();
  }

  /// One of the little boxes of a classroom: the number of the period, filled
  /// when the classroom is taken then.
  ///
  /// The period which is going on is marked with a plain ring rather than with a
  /// colour of its own: the colour of a box already says whether the classroom is
  /// taken or free, and a third colour next to them only fights with them.
  Widget getIcon(bool isUsed, {int? index, bool isNow = false}) {
    final scheme = Theme.of(context).colorScheme;
    final border = isNow ? scheme.onSurface : scheme.primary;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isUsed ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: index != null
          ? Text(
              index.toString(),
              style: TextStyle(
                fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                color: isUsed
                    ? scheme.onPrimary
                    : (isNow ? scheme.onSurface : scheme.primary),
              ),
            ).center()
          : null,
    ).decorated(
      border: Border.all(width: isNow ? 2 : 1, color: border),
      borderRadius: BorderRadius.circular(6),
    );
  }

  /// How many classrooms of the chosen building are free at this very moment,
  /// with the switch which hides the ones which are not.
  ///
  /// It is only worth showing for today, and only while there is a class period
  /// to talk about.
  Widget nowSummary() {
    final scheme = Theme.of(context).colorScheme;
    final period = nowPeriod;
    final label = period == null
        ? FlutterI18n.translate(context, "empty_classroom.classes_over")
        : FlutterI18n.translate(
            context,
            isNowOngoing
                ? "empty_classroom.now_ongoing"
                : "empty_classroom.now_upcoming",
            translationParams: {
              "period": "$period",
              "start": timeList[(period - 1) * 2],
              "end": timeList[(period - 1) * 2 + 1],
            },
          );
    final free = period == null
        ? 0
        : fetchedData.where((item) => !item.isUsed[period - 1]).length;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 16, color: scheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                if (period != null)
                  Text(
                    FlutterI18n.translate(
                      context,
                      "empty_classroom.now_free",
                      translationParams: {
                        "free": "$free",
                        "total": "${fetchedData.length}",
                      },
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
              ],
            ),
          ),
          if (period != null)
            FilterChip(
              label: Text(
                FlutterI18n.translate(context, "empty_classroom.only_free_now"),
              ),
              selected: onlyFreeNow,
              onSelected: (value) => setState(() => onlyFreeNow = value),
            ),
        ],
      ),
    );
  }

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

                                /// 「只看现在空闲」是给今天准备的，换到别的日子
                                /// 就没有意义了。
                                onlyFreeNow = false;
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
              if (state == SessionState.fetched && isToday) nowSummary(),
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
        else if (data.isEmpty && onlyFreeNow)
          Center(
            child: Text(
              FlutterI18n.translate(context, "empty_classroom.no_free_now"),
            ),
          ).expanded()
        else
          ListView.separated(
            itemCount: data.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ).withSafeBottom(context),
            itemBuilder: (context, index) {
              final item = data[index];
              final now = nowPeriod;
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
                        (i) => getIcon(
                          item.isUsed[i],
                          index: i + 1,
                          isNow: now == i + 1,
                        ),
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
                        (i) => getIcon(
                          item.isUsed[i + 4],
                          index: i + 5,
                          isNow: now == i + 5,
                        ),
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
                        (i) => getIcon(
                          item.isUsed[i + 8],
                          index: i + 9,
                          isNow: now == i + 9,
                        ),
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
