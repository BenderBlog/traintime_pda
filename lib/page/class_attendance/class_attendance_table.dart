// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA Authors
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attendance_detail.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';

class ClassAttendanceTable extends StatefulWidget {
  final List<ClassAttendance> courses;
  final Map<String, int> classTimes;
  final Future<void> Function() onRefresh;

  const ClassAttendanceTable({
    super.key,
    required this.courses,
    required this.classTimes,
    required this.onRefresh,
  });

  @override
  State<ClassAttendanceTable> createState() => _ClassAttendanceTableState();
}

class _ClassAttendanceTableState extends State<ClassAttendanceTable> {
  String? _selectedFilter;
  int? _sortColumnIndex = 1; // 默认按状态列排序
  bool _sortAscending = true;

  int _getStatusPriority(String status) {
    if (status.contains("ineligible")) return 0; // 最高优先级
    if (status.contains("warning")) return 1;
    if (status.contains("eligible")) return 2;
    return 3; // unknown 最低优先级
  }

  List<ClassAttendance> get _filteredCourses {
    List<ClassAttendance> filtered;

    if (_selectedFilter == null || _selectedFilter == 'all') {
      filtered = widget.courses.toList();
    } else {
      filtered = widget.courses.where((course) {
        final totalTimes = widget.classTimes[course.courseName] ?? 0;
        final status = course.getAttendanceStatus(totalTimes);
        return status == _selectedFilter;
      }).toList();
    }

    // 应用排序
    if (_sortColumnIndex != null) {
      filtered.sort((a, b) {
        int comparison = 0;
        final totalTimesA = widget.classTimes[a.courseName] ?? 0;
        final totalTimesB = widget.classTimes[b.courseName] ?? 0;

        switch (_sortColumnIndex) {
          case 0: // 课程名称
            comparison = a.courseName.compareTo(b.courseName);
            break;
          case 1: // 状态
            final statusA = a.getAttendanceStatus(totalTimesA);
            final statusB = b.getAttendanceStatus(totalTimesB);
            comparison = _getStatusPriority(
              statusA,
            ).compareTo(_getStatusPriority(statusB));
            break;
          case 2: // 到课率
            final rateA =
                double.tryParse(a.attendanceRate.replaceAll(" %", "")) ?? 0;
            final rateB =
                double.tryParse(b.attendanceRate.replaceAll(" %", "")) ?? 0;
            comparison = rateA.compareTo(rateB);
            break;
          case 3: // 签到
            final checkInA = int.tryParse(a.checkInCount) ?? 0;
            final checkInB = int.tryParse(b.checkInCount) ?? 0;
            comparison = checkInA.compareTo(checkInB);
            break;
          case 4: // 缺勤
            final absenceA = int.tryParse(a.absenceCount) ?? 0;
            final absenceB = int.tryParse(b.absenceCount) ?? 0;
            comparison = absenceA.compareTo(absenceB);
            break;
          case 5: // 应签
            final requiredA = int.tryParse(a.requiredCheckIn) ?? 0;
            final requiredB = int.tryParse(b.requiredCheckIn) ?? 0;
            comparison = requiredA.compareTo(requiredB);
            break;
        }

        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  Color _getStatusColor(String status) {
    if (status.contains("ineligible")) {
      return Colors.red;
    } else if (status.contains("warning")) {
      return Colors.orange;
    } else if (status.contains("eligible")) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildFilterRow(
    BuildContext context,
    List<ClassAttendance> filteredCourses,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            FlutterI18n.translate(context, "class_attendance.table.filter"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      FlutterI18n.translate(
                        context,
                        "class_attendance.table.filter_all",
                      ),
                    ),
                    selected:
                        _selectedFilter == null || _selectedFilter == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? 'all' : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(
                      FlutterI18n.translate(
                        context,
                        "class_attendance.course_state.ineligible",
                      ),
                    ),
                    selected:
                        _selectedFilter ==
                        'class_attendance.course_state.ineligible',
                    selectedColor: Colors.red.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected
                            ? 'class_attendance.course_state.ineligible'
                            : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(
                      FlutterI18n.translate(
                        context,
                        "class_attendance.course_state.warning",
                      ),
                    ),
                    selected:
                        _selectedFilter ==
                        'class_attendance.course_state.warning',
                    selectedColor: Colors.orange.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected
                            ? 'class_attendance.course_state.warning'
                            : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(
                      FlutterI18n.translate(
                        context,
                        "class_attendance.course_state.eligible",
                      ),
                    ),
                    selected:
                        _selectedFilter ==
                        'class_attendance.course_state.eligible',
                    selectedColor: Colors.green.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected
                            ? 'class_attendance.course_state.eligible'
                            : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(
                      FlutterI18n.translate(
                        context,
                        "class_attendance.course_state.unknown",
                      ),
                    ),
                    selected:
                        _selectedFilter ==
                        'class_attendance.course_state.unknown',
                    selectedColor: Colors.grey.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected
                            ? 'class_attendance.course_state.unknown'
                            : null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Text(
            FlutterI18n.translate(
              context,
              "class_attendance.table.showing_count",
              translationParams: {
                "count": filteredCourses.length.toString(),
                "total": widget.courses.length.toString(),
              },
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _filteredCourses;

    return Column(
      children: [
        _buildFilterRow(context, filteredCourses),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn(
                      label: Text(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.table.course_name",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: Text(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.table.status",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: Text(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.table.attendance_rate",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: Text(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.table.check_in",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: Text(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.table.absence",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: Text(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.table.required",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          _sortColumnIndex = columnIndex;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: Text(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.table.leave",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  rows: filteredCourses.map((course) {
                    final totalTimes =
                        widget.classTimes[course.courseName] ?? 0;
                    final status = course.getAttendanceStatus(totalTimes);
                    final statusColor = _getStatusColor(status);

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            course.courseName,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            if (!status.contains("unknown")) {
                              await BothSideSheet.show(
                                context: context,
                                title: FlutterI18n.translate(
                                  context,
                                  "class_attendance.detail_title",
                                  translationParams: {
                                    "courseName": course.courseName,
                                  },
                                ),
                                child: ClassAttendanceDetailView(
                                  classAttendance: course,
                                  showAppBar: false,
                                ),
                              );
                            }
                          },
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              FlutterI18n.translate(context, status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(course.attendanceRate)),
                        DataCell(Text(course.checkInCount)),
                        DataCell(
                          Text(
                            course.absenceCount,
                            style: TextStyle(
                              color:
                                  int.tryParse(course.absenceCount) != null &&
                                      int.parse(course.absenceCount) > 0
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                        ),
                        DataCell(Text(course.requiredCheckIn)),
                        DataCell(
                          Text(
                            "${course.personalLeave}/${course.sickLeave}/${course.officialLeave}",
                            style: const TextStyle(fontSize: 12),
                            softWrap: true,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
