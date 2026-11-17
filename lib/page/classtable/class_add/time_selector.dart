// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/wheel_choser.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class TimeSelector extends StatefulWidget {
  final int initialWeekday;
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;
  final ValueChanged<(int weekday, TimeOfDay start, TimeOfDay end)> onChanged;
  final Color color;

  const TimeSelector({
    super.key,
    required this.initialWeekday,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.onChanged,
    required this.color,
  });

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  late int weekday;
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  static const int _earliestTime = 8 * 60 + 30;
  static const int _latestTime = 21 * 60 + 25;

  @override
  void initState() {
    super.initState();
    weekday = widget.initialWeekday;
    startTime = widget.initialStartTime;
    endTime = widget.initialEndTime;
  }

  void _notifyChange() {
    widget.onChanged((weekday, startTime, endTime));
  }

  Future<void> _chooseTime({required bool isStart}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (selected == null || !mounted) return;

    final minutes = selected.hour * 60 + selected.minute;
    if (minutes < _earliestTime || minutes > _latestTime) {
      showToast(
        context: context,
        msg: context.t.classtable.classAdd.dateSelectorFree.rule,
      );
      return;
    }

    setState(() {
      if (isStart) {
        startTime = selected;
      } else {
        endTime = selected;
      }
    });
    _notifyChange();
  }

  Widget _timeButton({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, textAlign: TextAlign.center).textColor(widget.color),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.schedule),
            label: Text(time.format(context)),
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.color,
              side: BorderSide(color: widget.color.withValues(alpha: 0.25)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: widget.color, size: 16),
              Text(
                context.t.classtable.classAdd.inputTimeHint,
              ).textStyle(TextStyle(color: widget.color)).padding(left: 4),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      context.t.classtable.classAdd.inputTimeWeekdayHint,
                    ).textColor(widget.color),
                    SizedBox(
                      height: 90,
                      child: WheelChoose<int>(
                        changeBookIdCallBack: (value) {
                          setState(() => weekday = value + 1);
                          _notifyChange();
                        },
                        defaultPage: weekday - 1,
                        options: List.generate(
                          7,
                          (index) => WheelChooseOptions(
                            data: index,
                            hint: getWeekString(context, index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _timeButton(
                label: context.t.classtable.classAdd.inputStartTimeHint,
                time: startTime,
                onTap: () => _chooseTime(isStart: true),
              ),
              const SizedBox(width: 8),
              _timeButton(
                label: context.t.classtable.classAdd.inputEndTimeHint,
                time: endTime,
                onTap: () => _chooseTime(isStart: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
