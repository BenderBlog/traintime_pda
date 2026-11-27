// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_list.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/model/class_organized_data.dart';
import 'package:watermeter/page/classtable/model/classtable_widget_state.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/model/style_config/glass_style_config.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail_data.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_scope.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/themes/color_seed.dart';

/// The card in [classSubRow], mentioned in [ClassTableView].
class ClassCard extends StatelessWidget {
  final ClassOrgainzedData detail;
  final double completedHeight;

  /// The height inside the card's padding, which the completed split is measured against.
  ///
  /// Handed in rather than measured with a [LayoutBuilder]: the card sits in a slot whose height
  /// [ClassTableView] already knows, and measuring it inside the card would move its subtree build
  /// into the layout phase and add a render object per card for a number that is right here.
  final double height;

  /// The width the card was given, which the text shrinks with on a narrow table.
  ///
  /// Handed in for the same reason as [height]: the table already knows the width it
  /// positioned the card at, and measuring it again here would rebuild every card on every
  /// frame of a drag.
  final double width;

  List<dynamic> get data => detail.data;
  MaterialColor get color => detail.color;
  String get name => detail.name;
  String? get place => detail.place;
  const ClassCard({
    super.key,
    required this.detail,
    required this.completedHeight,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final classTableState = ClasstableScope.of(context);
    final activeStyle = CompletedClassStyle.resolve(
      palette: color,
      isCompleted: false,
    );
    final completedStyle = CompletedClassStyle.resolve(
      palette: color,
      isCompleted: true,
    );
    final bool isPhoneDevice = isPhone(context);

    final splitHeight = completedHeight.clamp(0.0, height);
    final isCompleted = splitHeight >= height - 0.5;
    final textStyle = isCompleted ? completedStyle : activeStyle;
    final borderStyle = isCompleted ? completedStyle : activeStyle;

    /// Seven days have to fit next to the index row, and in a floating
    /// window or in a split screen much less room is left for each of
    /// them. The regular sizes would then break the name of a class
    /// into one or two characters per line, and the lines which do not
    /// fit in the card are cut off, so the text shrinks with the card.
    final cardWidth = width;
    final isNarrowCard = cardWidth < narrowClassCardWidth;
    final isTinyCard = cardWidth < tinyClassCardWidth;
    final nameFontSize = isTinyCard
        ? 9.0
        : isNarrowCard
        ? 10.0
        : (isPhoneDevice ? 12.0 : 14.0);
    final detailFontSize = isTinyCard
        ? 7.0
        : isNarrowCard
        ? 9.0
        : (isPhoneDevice ? 10.0 : 12.0);

    const borderRadius = BorderRadius.all(Radius.circular(8));
    return Padding(
      padding: const EdgeInsets.all(classCardContentInset),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// The frosted background: a real backdrop blur of the wallpaper behind the card.
            ///
            /// Grouped with the other cards, so a whole tableful shares one blur of the same
            /// backdrop.
            Positioned.fill(
              child: GlassBlur(
                grouped: true,
                sigma: GlassStyleConfig.cardSigma,
                child: const SizedBox.expand(),
              ),
            ),
            if (splitHeight > 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: splitHeight,
                child: Container(
                  color: completedStyle.innerColor.withValues(
                    alpha: completedStyle.innerAlpha,
                  ),
                ),
              ),
            if (splitHeight < height)
              Positioned(
                top: splitHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: activeStyle.innerColor.withValues(
                    alpha: activeStyle.innerAlpha,
                  ),
                ),
              ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final controller = ClasstableScope.read(context);

                /// The way to show the class info of the period.
                /// The last one indicate whether to delete this stuff.
                final semesterWeekCount = classTableState.semesterLength;
                final semesterStartDay = classTableState.startDay;
                final weekStartDates = List.generate(
                  semesterWeekCount,
                  (week) => semesterStartDay.add(Duration(days: week * 7)),
                );
                final action = await BothSideSheet.show(
                  title: context.t.classtable.classCard.title,
                  child: ArrangementDetail(
                    data: ArrangementDetailData(
                      arrangements: data
                          .map((entry) => _toDetailItem(entry, classTableState))
                          .toList(),
                      semesterWeekCount: semesterWeekCount,
                      weekStartDates: weekStartDates,
                      currentWeek: classTableState.currentWeek,
                    ),
                  ),
                  context: context,
                );
                if (!context.mounted || action == null) return;

                if (action is ArrangementDetailAction) {
                  final int customIndex = controller.customClasses.indexWhere(
                    (custom) => custom.id == action.customClassId,
                  );
                  if (customIndex < 0) return;

                  if (action.type == CustomCourseActionType.deleteAll) {
                    await controller.deleteCustomClassById(
                      action.customClassId,
                    );
                  } else if (action.type == CustomCourseActionType.deleteOne) {
                    final String? timeRangeId = action.customTimeRangeId;
                    if (timeRangeId == null) return;
                    await controller.deleteCustomClassTimeRange(
                      customClassId: action.customClassId,
                      timeRangeId: timeRangeId,
                    );
                  } else if (action.type == CustomCourseActionType.edit) {
                    final CustomClass customClass =
                        controller.customClasses[customIndex];
                    await Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => ClassAddWindow(
                              state: controller,
                              customToChange: customClass,
                            ),
                          ),
                        )
                        .then((value) async {
                          if (value is CustomClass) {
                            await controller.editCustomClassById(
                              action.customClassId,
                              value,
                            );
                          }
                        });
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPhoneDevice ? 2 : 4,
                  vertical: isNarrowCard ? 2 : 4,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: textStyle.textColor,
                            fontSize: nameFontSize,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      Text(
                        "@${place ?? context.t.classtable.classCard.unknownClassroom}",
                        style: TextStyle(
                          color: textStyle.textColor,
                          fontSize: detailFontSize,
                        ),
                      ),
                      if (data.length > 1)
                        Text(
                          context.t.classtable.classCard.remainsHint(
                            remain_count: (data.length - 1).toString(),
                          ),
                          style: TextStyle(
                            color: textStyle.textColor,
                            fontSize: detailFontSize,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (data.length > 1)
              ClipPath(
                clipper: Triangle(),
                child: Container(
                  color: textStyle.borderColor,
                ).constrained(width: 8, height: 8),
              ).alignment(Alignment.topRight),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: borderStyle.borderColor.withValues(
                        alpha: borderStyle.borderAlpha,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ArrangementDetailItem _toDetailItem(
    dynamic entry,
    ClasstableWidgetState classTableState,
  ) {
    if (entry is Subject) {
      final start = entry.startTime;
      final end = entry.stopTime;
      return ArrangementDetailItem(
        type: ArrangementDetailType.exam,
        name: '${entry.subject}${entry.type}',
        color: detail.color,
        classroom: entry.place,
        seat: entry.seat,
        dateRanges: start != null && end != null
            ? [DateTimeRange(start: start, end: end)]
            : const [],
      );
    }
    if (entry is ExperimentData) {
      return ArrangementDetailItem(
        type: entry.type == ExperimentType.physics
            ? ArrangementDetailType.physicsExperiment
            : ArrangementDetailType.otherExperiment,
        name: entry.name,
        color: detail.color,
        teacher: entry.teacher,
        classroom: entry.classroom,
        dateRanges: entry.timeRanges
            .map((range) => DateTimeRange(start: range.$1, end: range.$2))
            .toList(),
      );
    }
    if (entry is (CustomClass, CustomClassTimeRange, MaterialColor)) {
      final (customClass, selectedRange, customColor) = entry;
      return ArrangementDetailItem(
        type: ArrangementDetailType.customCourse,
        name: customClass.name,
        color: customColor,
        teacher: customClass.teacher,
        classroom: customClass.classroom,
        dateRanges: customClass.timeRanges
            .map(
              (range) =>
                  DateTimeRange(start: range.startTime, end: range.endTime),
            )
            .toList(),
        selectedDateRange: DateTimeRange(
          start: selectedRange.startTime,
          end: selectedRange.endTime,
        ),
        customClassId: customClass.id,
        customTimeRangeId: selectedRange.id,
      );
    }
    if (entry is (CustomClass, CustomClassTimeRange)) {
      final (customClass, selectedRange) = entry;
      return ArrangementDetailItem(
        type: ArrangementDetailType.customCourse,
        name: customClass.name,
        color: colorList.first,
        teacher: customClass.teacher,
        classroom: customClass.classroom,
        dateRanges: customClass.timeRanges
            .map(
              (range) =>
                  DateTimeRange(start: range.startTime, end: range.endTime),
            )
            .toList(),
        selectedDateRange: DateTimeRange(
          start: selectedRange.startTime,
          end: selectedRange.endTime,
        ),
        customClassId: customClass.id,
        customTimeRangeId: selectedRange.id,
      );
    }
    if (entry is TimeArrangement) {
      final arrangementIndex = classTableState.timeArrangement.indexOf(entry);
      final classDetail = classTableState.getClassDetail(
        classTableState.timeArrangement.indexOf(entry),
      );
      final day = classTableState.startDay.add(Duration(days: entry.day - 1));
      DateTime atPeriodTime(int timeIndex) {
        final parts = timeList[timeIndex].split(':');
        return DateTime(
          day.year,
          day.month,
          day.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }

      return ArrangementDetailItem(
        type: ArrangementDetailType.course,
        name: classDetail.name,
        color: colorList[arrangementIndex % colorList.length],
        teacher: entry.teacher,
        classroom: entry.classroom,
        weekList: entry.weekList,
        weekday: entry.day,
        startPeriod: entry.start,
        stopPeriod: entry.stop,
        code: classDetail.code,
        number: classDetail.number,
        dateRanges: [
          DateTimeRange(
            start: atPeriodTime((entry.start - 1) * 2),
            end: atPeriodTime((entry.stop - 1) * 2 + 1),
          ),
        ],
      );
    }
    throw ArgumentError.value(entry, 'entry', 'Unsupported arrangement');
  }
}

class Triangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addPolygon([
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width, size.height),
    ], true);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
