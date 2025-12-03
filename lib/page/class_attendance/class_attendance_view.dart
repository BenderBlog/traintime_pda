// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA Authors
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attandance_card.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_ids/learning_session.dart';

class ClassAttendanceView extends StatefulWidget {
  const ClassAttendanceView({super.key});

  @override
  State<ClassAttendanceView> createState() => _ClassAttendanceViewState();
}

class _ClassAttendanceViewState extends State<ClassAttendanceView> {
  late Future<List<ClassAttendance>> _coursesFuture;

  Future<List<ClassAttendance>> loadDataFunction() async =>
      LearningSession().getAttandanceRecord();

  @override
  void initState() {
    super.initState();
    // 首次进入页面时开始加载数据
    _coursesFuture = loadDataFunction();
  }

  // 下拉刷新时调用的函数
  Future<void> _refreshData() async {
    setState(() {
      _coursesFuture = loadDataFunction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('课程考勤与进度')),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<ClassAttendance>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('加载数据失败: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('没有找到课程数据。'));
            }

            final courses = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) => AlignedGridView.count(
                shrinkWrap: true,
                itemCount: courses.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                crossAxisCount: constraints.maxWidth ~/ 280,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                itemBuilder: (context, index) {
                  return CourseCard(course: courses[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
