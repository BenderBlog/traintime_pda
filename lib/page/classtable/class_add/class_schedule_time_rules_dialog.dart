// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/model/time_list.dart';

const double _scheduleListTileHeight = 56;
const double _scheduleListTileOuterRadius = 12;

enum _TimeMode { presets, custom }

/// TimeRange
class ClassScheduleTimeRange {
  const ClassScheduleTimeRange._({required this.start, required this.end});

  final TimeOfDay start;
  final TimeOfDay end;

  int get _startMinutes => start.hour * 60 + start.minute;
  int get _endMinutes => end.hour * 60 + end.minute;

  bool get _isWithinAllowedTime =>
      _startMinutes >= 8 * 60 + 30 &&
      _startMinutes <= 21 * 60 + 25 &&
      _endMinutes >= 8 * 60 + 30 &&
      _endMinutes <= 21 * 60 + 25;

  bool get _isOrdered => _startMinutes < _endMinutes;
}

class ClassScheduleTimeSelection {
  const ClassScheduleTimeSelection._({
    required _TimeMode mode,
    required Set<int> presetIndices,
    required List<ClassScheduleTimeRange> customRanges,
  }) : _mode = mode,
       _presetIndices = presetIndices,
       _customRanges = customRanges;

  final _TimeMode _mode;
  final Set<int> _presetIndices;
  final List<ClassScheduleTimeRange> _customRanges;

  /// 拿到有效的时间区间，对于自定义时间段保持原样；对于预设时间段转换为 TimeOfDay
  List<ClassScheduleTimeRange> get activeRanges {
    if (_mode == _TimeMode.custom) return _customRanges;
    final indices = _presetIndices.toList()..sort();
    return [for (final index in indices) _presets[index].range];
  }
}

class _Preset {
  const _Preset({
    required this.startPeriod,
    required this.endPeriod,
    required this.startTimeIndex,
    required this.endTimeIndex,
  });

  final int startPeriod;
  final int endPeriod;
  final int startTimeIndex;
  final int endTimeIndex;

  ClassScheduleTimeRange get range => ClassScheduleTimeRange._(
    start: _timeOfDay(timeList[startTimeIndex]),
    end: _timeOfDay(timeList[endTimeIndex]),
  );
}

const _presets = [
  _Preset(startPeriod: 1, endPeriod: 2, startTimeIndex: 0, endTimeIndex: 3),
  _Preset(startPeriod: 3, endPeriod: 4, startTimeIndex: 4, endTimeIndex: 7),
  _Preset(startPeriod: 5, endPeriod: 6, startTimeIndex: 8, endTimeIndex: 11),
  _Preset(startPeriod: 7, endPeriod: 8, startTimeIndex: 12, endTimeIndex: 15),
  _Preset(startPeriod: 9, endPeriod: 10, startTimeIndex: 16, endTimeIndex: 19),
];

TimeOfDay _timeOfDay(String value) {
  final parts = value.split(':').map(int.parse).toList();
  return TimeOfDay(hour: parts[0], minute: parts[1]);
}

String _presetLabel(BuildContext context, _Preset preset) => context
    .t
    .classtable
    .courseDetailCard
    .classPeriod(start: preset.startPeriod, stop: preset.endPeriod);

String _formatTime(BuildContext context, TimeOfDay time) =>
    MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(time, alwaysUse24HourFormat: true);

class ClassScheduleTimeSummary extends StatelessWidget {
  const ClassScheduleTimeSummary({super.key, required this.selection});

  final ClassScheduleTimeSelection selection;

  String _formatRange(BuildContext context, ClassScheduleTimeRange range) =>
      '${_formatTime(context, range.start)}–${_formatTime(context, range.end)}';

  @override
  Widget build(BuildContext context) {
    final ranges = selection.activeRanges;
    final children = <Widget>[];
    if (selection._mode == _TimeMode.presets) {
      final indices = selection._presetIndices.toList()..sort();
      for (final index in indices) {
        final preset = _presets[index];
        children.add(
          M3EListItem(
            key: ValueKey('preset-$index'),
            minHeight: _scheduleListTileHeight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            headline: Text(
              '${_presetLabel(context, preset)} ${_formatRange(context, ranges[children.length])}',
            ),
          ),
        );
      }
    } else {
      for (var index = 0; index < ranges.length; index++) {
        children.add(
          M3EListItem(
            key: ValueKey('custom-$index'),
            minHeight: _scheduleListTileHeight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            headline: Text(
              '${context.t.classtable.classAdd.scheduleBuilder.timeRangeTitle(index: index + 1)} ${_formatRange(context, ranges[index])}',
            ),
          ),
        );
      }
    }
    return M3ESegmentedColumn(
      outerRadius: _scheduleListTileOuterRadius,
      gap: 2,
      padding: EdgeInsets.zero,
      children: children,
    );
  }
}

class ClassScheduleTimeRulesDialog extends StatefulWidget {
  const ClassScheduleTimeRulesDialog({
    super.key,
    required this.initialSelection,
  });

  final ClassScheduleTimeSelection? initialSelection;

  @override
  State<ClassScheduleTimeRulesDialog> createState() =>
      _ClassScheduleTimeRulesDialogState();
}

class _ClassScheduleTimeRulesDialogState
    extends State<ClassScheduleTimeRulesDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Set<int> _presetIndices;
  late List<ClassScheduleTimeRange> _customRanges;
  late int _currentTab;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelection;
    _presetIndices = Set.of(initial?._presetIndices ?? const {});
    _customRanges = List.of(initial?._customRanges ?? const []);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initial?._mode == _TimeMode.custom ? 1 : 0,
    );
    _currentTab = _tabController.index;
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index == _currentTab) return;
    _currentTab = _tabController.index;
    if (mounted) setState(() => _error = null);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _editTime(int index, {required bool isStart}) async {
    final range = _customRanges[index];
    final current = isStart ? range.start : range.end;
    final selected = await Navigator.of(context).push<TimeOfDay>(
      DialogRoute<TimeOfDay>(
        context: context,
        builder: (_) => TimePickerDialog(initialTime: current),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _customRanges[index] = ClassScheduleTimeRange._(
        start: isStart ? selected : range.start,
        end: isStart ? range.end : selected,
      );
      _error = null;
    });
  }

  void _confirm() {
    final mode = _tabController.index == 0
        ? _TimeMode.presets
        : _TimeMode.custom;
    final ranges = mode == _TimeMode.presets
        ? [
            for (final index in (_presetIndices.toList()..sort()))
              _presets[index].range,
          ]
        : _customRanges;
    // 错误处理的两种情况
    if (ranges.any((range) => !range._isWithinAllowedTime)) {
      setState(
        () => _error = context.t.classtable.classAdd.scheduleBuilder.timeRule,
      );
      return;
    }
    if (ranges.any((range) => !range._isOrdered)) {
      setState(
        () => _error =
            context.t.classtable.classAdd.scheduleBuilder.timeOrderRule,
      );
      return;
    }
    Navigator.of(context).pop(
      ClassScheduleTimeSelection._(
        mode: mode,
        presetIndices: Set.unmodifiable(_presetIndices),
        customRanges: List.unmodifiable(_customRanges),
      ),
    );
  }

  Widget _buildPresetTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12),
      child: M3ESegmentedColumn(
        outerRadius: _scheduleListTileOuterRadius,
        gap: 2,
        padding: EdgeInsets.zero,
        selectionMode: M3ESelectionMode.multiple,
        selectionTrigger: M3ESelectionTrigger.tap,
        selectedIndices: _presetIndices,
        color: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.primaryContainer,
        onSelectionChanged: (indices) => setState(() {
          _presetIndices = indices;
          _error = null;
        }),
        children: [
          for (var index = 0; index < _presets.length; index++)
            Builder(
              builder: (context) {
                final selected = _presetIndices.contains(index);
                return M3EListItem(
                  minHeight: _scheduleListTileHeight,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  headlineStyle: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                  headline: Text(
                    '${_presetLabel(context, _presets[index])} ${_formatRange(_presets[index].range)}',
                  ),
                  trailing: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Icon(
                      key: ValueKey(selected),
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 20,
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCustomTab(BuildContext context) {
    final tr = context.t;
    final builder = tr.classtable.classAdd.scheduleBuilder;
    return Column(
      children: [
        Expanded(
          child: _customRanges.isEmpty
              ? Center(child: Text(builder.emptySelection))
              : ListView(
                  padding: const EdgeInsets.only(top: 12),
                  children: [
                    M3ESegmentedColumn(
                      outerRadius: _scheduleListTileOuterRadius,
                      gap: 2,
                      padding: EdgeInsets.zero,
                      children: [
                        for (
                          var index = 0;
                          index < _customRanges.length;
                          index++
                        )
                          M3EListItem(
                            key: ValueKey('custom-$index'),
                            minHeight: _scheduleListTileHeight,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            trailingSpacing: 8,
                            headline: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    builder.timeRangeTitle(index: index + 1),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Tooltip(
                                  message: tr
                                      .classtable
                                      .classAdd
                                      .scheduleBuilder
                                      .startTime,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(56, 40),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () =>
                                        _editTime(index, isStart: true),
                                    child: Text(
                                      _formatTime(
                                        context,
                                        _customRanges[index].start,
                                      ),
                                    ),
                                  ),
                                ),
                                const Text('–'),
                                Tooltip(
                                  message: tr
                                      .classtable
                                      .classAdd
                                      .scheduleBuilder
                                      .endTime,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(56, 40),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () =>
                                        _editTime(index, isStart: false),
                                    child: Text(
                                      _formatTime(
                                        context,
                                        _customRanges[index].end,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              tooltip: tr.classtable.courseDetailCard.delete,
                              onPressed: () => setState(() {
                                _customRanges.removeAt(index);
                                _error = null;
                              }),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _customRanges.add(
              const ClassScheduleTimeRange._(
                start: TimeOfDay(hour: 8, minute: 30),
                end: TimeOfDay(hour: 10, minute: 5),
              ),
            );
            _error = null;
          }),
          icon: const Icon(Icons.add),
          label: Text(builder.addTimeRange),
        ),
      ],
    );
  }

  String _formatRange(ClassScheduleTimeRange range) =>
      '${_formatTime(context, range.start)}–${_formatTime(context, range.end)}';

  @override
  Widget build(BuildContext context) {
    final translations = context.t.classtable.classAdd.scheduleBuilder;
    final dialogHeight = (MediaQuery.sizeOf(context).height * 0.5)
        .clamp(240.0, 420.0)
        .toDouble();

    return AlertDialog(
      title: Text(translations.selectTimes),
      content: SizedBox(
        width: 440,
        height: dialogHeight,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: translations.presets),
                Tab(text: translations.custom),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPresetTab(context), _buildCustomTab(context)],
              ),
            ),
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.common.cancel),
        ),
        FilledButton(
          onPressed: _confirm,
          child: Text(context.t.common.confirm),
        ),
      ],
    );
  }
}
