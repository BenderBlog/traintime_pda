// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/system_calendar_sync_service.dart';

class ClassRefreshTile extends StatelessWidget {
  const ClassRefreshTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MingCuteIcons.mgc_refresh_2_line),
      title: Text(FlutterI18n.translate(context, "setting.class_refresh")),
      trailing: const Icon(Icons.navigate_next),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => const _ClassRefreshDialog(),
      ),
    );
  }
}

class _ClassRefreshDialog extends StatelessWidget {
  const _ClassRefreshDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        FlutterI18n.translate(context, "setting.class_refresh_title"),
      ),
      content: Text(
        FlutterI18n.translate(context, "setting.class_refresh_content"),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(FlutterI18n.translate(context, "cancel")),
        ),
        TextButton(
          onPressed: () async {
            await Future.wait([
              ClassTableController.i.reloadClassTable(),
              ExamController.i.reloadExamInfo(),
              if (!preference.getBool(preference.Preference.role)) ...[
                PhysicsExperimentController.i.reloadPhysicsExperiment(),
                OtherExperimentController.i.reloadOtherExperiment(),
              ],
            ]);
            await maybeAutoSyncSystemCalendar();
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(FlutterI18n.translate(context, "confirm")),
        ),
      ],
    );
  }
}
