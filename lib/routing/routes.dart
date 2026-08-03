// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/class_attendance/class_attendance_view.dart';
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/dorm_water/dorm_water_window.dart';
import 'package:watermeter/page/empty_classroom/empty_classroom_window.dart';
import 'package:watermeter/page/energy/electricity_window.dart';
import 'package:watermeter/page/exam/exam_info_window.dart';
import 'package:watermeter/page/experiment/experiment_window.dart';
import 'package:watermeter/page/library/library_window.dart';
import 'package:watermeter/page/schoolcard/school_card_window.dart';
import 'package:watermeter/page/schoolnet/network_card_window.dart';
import 'package:watermeter/page/score/score_window.dart';
import 'package:watermeter/page/setting/about_page/about_page.dart';
import 'package:watermeter/page/sport/sport_window.dart';

class Routes {
  Routes._();

  // Route name constants
  static const classAttendance = '/class-attendance';
  static const score = '/score';
  static const exam = '/exam';
  static const classTable = '/class-table';
  static const about = '/about';
  static const sport = '/sport';
  static const networkCard = '/network-card';
  static const experiment = '/experiment';
  static const emptyClassroom = '/empty-classroom';
  static const dormWater = '/dorm-water';
  static const schoolCard = '/school-card';
  static const library = '/library';
  static const electricity = "/electricity";

  static Widget _resolve(String name, Object? arguments) {
    return switch (name) {
      classAttendance => const ClassAttendanceView(),
      score => const ScoreWindow(),
      exam => const ExamInfoWindow(),
      classTable => LayoutBuilder(
        builder: (context, constraints) =>
            ClassTableWindow(constraints: constraints),
      ),
      about => const AboutPage(),
      sport => const SportWindow(),
      networkCard => const NetworkCardWindow(),
      experiment => const ExperimentWindow(),
      emptyClassroom => const EmptyClassroomWindow(),
      dormWater => const DormWaterWindow(),
      schoolCard => const SchoolCardWindow(),
      library => const LibraryWindow(),
      electricity => const ElectricityWindow(),
      _ => const SizedBox.shrink(),
    };
  }

  /// Build a [MaterialPageRoute] from a registered route name.
  static Route<T> resolveRoute<T extends Object?>(
    String name, {
    Object? arguments,
  }) {
    return MaterialPageRoute<T>(
      settings: RouteSettings(name: name, arguments: arguments),
      builder: (_) => _resolve(name, arguments),
    );
  }
}
