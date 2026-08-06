// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/page/setting/dialogs/semester_switch_dialog.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/system_calendar_sync_service.dart';

class ClasstableSection extends StatefulWidget {
  const ClasstableSection({super.key});

  @override
  State<ClasstableSection> createState() => _ClasstableSectionState();
}

class _ClasstableSectionState extends State<ClasstableSection> {
  /// TODO: Refactor calendar sync
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

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(context, "setting.classtable_setting"),
      items: [
        ListTile(
          title: Text(FlutterI18n.translate(context, "setting.background")),
          trailing: Switch(
            value: preference.getBool(preference.Preference.decorated),
            onChanged: (bool value) {
              if (value == true &&
                  !preference.getBool(preference.Preference.decoration)) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(context, "setting.no_background"),
                );
              } else {
                /// TODO: Check whether need setState
                setState(() {
                  preference.setBool(preference.Preference.decorated, value);
                });
              }
            },
          ),
        ),
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.choose_background"),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () async {
            PlatformFile? result;
            try {
              result = await pickFile(type: FileType.image);
            } on MissingStoragePermissionException {
              if (context.mounted) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(context, "setting.no_permission"),
                );
              }
            }
            if (mounted) {
              if (result != null) {
                File(result.path!).copySync(
                  "${supportPath.path}/${ClassTableController.decorationName}",
                );
                preference.setBool(preference.Preference.decoration, true);
                if (context.mounted) {
                  showToast(
                    context: context,
                    msg: FlutterI18n.translate(
                      context,
                      "setting.successful_setting",
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  showToast(
                    context: context,
                    msg: FlutterI18n.translate(
                      context,
                      "setting.failure_setting",
                    ),
                  );
                }
              }
            }
          },
        ),
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.clear_user_class"),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.clear_user_class_title",
                ),
              ),
              content: Text(
                FlutterI18n.translate(
                  context,
                  "setting.clear_user_class_content",
                ),
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
                    await CustomClassController.i.clearAll();
                    if (mounted) {
                      setState(() {});
                    }
                    showToast(
                      context: context,
                      msg: FlutterI18n.translate(
                        context,
                        "setting.clear_user_class_clear",
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(FlutterI18n.translate(context, "confirm")),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          title: Text(FlutterI18n.translate(context, "setting.class_refresh")),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
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
                      PhysicsExperimentController.i.reloadPhysicsExperiment(),
                      OtherExperimentController.i.reloadOtherExperiment(),
                    ]);
                    await maybeAutoSyncSystemCalendar();
                    if (mounted) {
                      setState(() {});
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(FlutterI18n.translate(context, "confirm")),
                ),
              ],
            ),
          ),
        ),

        /// TODO: Refactor class swift, explain goes to dialog, show current state
        ListTile(
          title: Text(FlutterI18n.translate(context, "setting.class_swift")),
          subtitle: Text(
            FlutterI18n.translate(
              context,
              "setting.class_swift_description",
              translationParams: {
                "swift": preference
                    .getInt(preference.Preference.swift)
                    .toString(),
              },
            ),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ChangeSwiftDialog(),
            ).then((value) {
              setState(() {});
            });
          },
        ),
        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.semester_change"),
          ),
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
          onTap: () {
            showDialog<bool>(
              barrierDismissible: false,
              context: context,
              builder: (context) => SemesterSwitchDialog(),
            ).then((value) async {
              if (value == true) {
                setState(() {});
                if (context.mounted) {
                  showToast(context: context, msg: "Updating data");
                }
                await _waitForSemesterAwareReloads();
                await maybeAutoSyncSystemCalendar();
                if (mounted) {
                  setState(() {});
                }
              }
            });
          },
        ),
      ],
    );
  }
}
