// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_ids/learning_session.dart';

class ClassAttendanceDetailView extends StatefulWidget {
  final ClassAttendance classAttendance;

  const ClassAttendanceDetailView({super.key, required this.classAttendance});

  @override
  State<ClassAttendanceDetailView> createState() =>
      _ClassAttendanceDetailViewState();
}

class _ClassAttendanceDetailViewState extends State<ClassAttendanceDetailView> {
  late Future<List<ClassAttendanceDetail>> future;

  @override
  void initState() {
    super.initState();
    future = LearningSession().getAttendanceRecordDetail(
      widget.classAttendance,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      future = LearningSession().getAttendanceRecordDetail(
        widget.classAttendance,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            "class_attendance.detail_title",
            translationParams: {
              "courseName": widget.classAttendance.courseName,
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<ClassAttendanceDetail>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ReloadWidget(
                function: _refreshData,
                errorStatus: snapshot.error,
                stackTrace: snapshot.stackTrace,
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyListView(
                text: FlutterI18n.translate(
                  context,
                  "class_attndance.no_attendance_record",
                ),
                type: EmptyListViewType.rolling,
              );
            } else {
              final details = snapshot.data!;
              return DataList(
                list: details,
                initFormula: (toUse) => ReXCard(
                  title: Text(FlutterI18n.translate(context, toUse.signName)),
                  remaining: [
                    ReXCardRemaining(
                      FlutterI18n.translate(context, toUse.signStatus),
                    ),
                  ],
                  bottomRow: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.detail_card.creator_name",
                        ),
                        toUse.creatorName,
                      ),
                      _buildInfoRow(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.detail_card.start_time",
                        ),
                        toUse.starttime,
                      ),
                      if (toUse.submittime != null)
                        _buildInfoRow(
                          FlutterI18n.translate(
                            context,
                            "class_attendance.detail_card.summit_time",
                          ),
                          toUse.submittime!,
                        ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
