// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/semester_settings_page.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/system_calendar_sync_service.dart';

class SemesterChangeTile extends StatefulWidget {
  const SemesterChangeTile({super.key});

  @override
  State<SemesterChangeTile> createState() => _SemesterChangeTileState();
}

class _SemesterChangeTileState extends State<SemesterChangeTile> {
  /// TODO: Refactor calendar sync.
  bool get _isSemesterAwareControllerLoading =>
      ClassTableController.i.schoolClassTableStateSignal.value.isLoading ||
      ExamController.i.examInfoStateSignal.value.isLoading ||
      PhysicsExperimentController
          .i
          .physicsExperimentStateSignal
          .value
          .isLoading ||
      OtherExperimentController.i.otherExperimentStateSignal.value.isLoading;

  Future<void> _waitForSemesterAwareReloads() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final stopwatch = Stopwatch()..start();
    while (_isSemesterAwareControllerLoading &&
        stopwatch.elapsed < const Duration(seconds: 30)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _changeSemester() async {
    final changed = await context.push<bool>(const SemesterSettingsPage());
    if (changed != true || !mounted) return;

    setState(() {});
    showToast(
      context: context,
      msg: FlutterI18n.translate(context, "setting.semester_update_data"),
    );
    await _waitForSemesterAwareReloads();
    await maybeAutoSyncSystemCalendar();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MingCuteIcons.mgc_calendar_month_line),
      title: Text(FlutterI18n.translate(context, "setting.semester_change")),
      subtitle: Text(
        FlutterI18n.translate(
          context,
          "setting.semester_change_description",
          translationParams: {
            "semester": preference.getString(
              preference.Preference.currentSemester,
            ),
          },
        ),
      ),
      trailing: const Icon(Icons.navigate_next),
      onTap: _changeSemester,
    );
  }
}
