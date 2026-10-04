// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/classtable_style_page/class_table_style_page.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/page/setting/dialogs/semester_switch_dialog.dart';
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
    return Column(
      children: [
        SectionSettingScaffold(
          title: FlutterI18n.translate(
            context,
            "setting.class_table_style_setting",
          ),
          items: SettingSegmentedList(
            items: [
              ListTile(
                leading: const Icon(MingCuteIcons.mgc_layout_grid_line),
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_setting",
                  ),
                ),
                subtitle: Text(
                  FlutterI18n.translate(
                    context,
                    "setting.class_table_style_description",
                  ),
                ),
                trailing: const Icon(Icons.navigate_next),
                onTap: () => context.push(const ClassTableStylePage()),
              ),
            ],
          ),
        ),
        SectionSettingScaffold(
          title: FlutterI18n.translate(context, 'setting.sections.semester'),
          items: SettingSegmentedList(
            items: [
              ListTile(
                leading: const Icon(MingCuteIcons.mgc_calendar_month_line),
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
                      if (mounted) setState(() {});
                      if (context.mounted) {
                        showToast(
                          context: context,
                          msg: FlutterI18n.translate(
                            context,
                            "setting.semester_update_data",
                          ),
                        );
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
              ListTile(
                leading: const Icon(MingCuteIcons.mgc_calendar_week_line),
                title: Text(
                  FlutterI18n.translate(context, "setting.class_swift"),
                ),
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
                    if (mounted) setState(() {});
                  });
                },
              ),
            ],
          ),
        ),
        SectionSettingScaffold(
          title: FlutterI18n.translate(context, 'setting.sections.course_data'),
          items: SettingSegmentedList(
            items: [
              ListTile(
                leading: const Icon(MingCuteIcons.mgc_refresh_2_line),
                title: Text(
                  FlutterI18n.translate(context, "setting.class_refresh"),
                ),
                trailing: const Icon(Icons.navigate_next),
                onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        "setting.class_refresh_title",
                      ),
                    ),
                    content: Text(
                      FlutterI18n.translate(
                        context,
                        "setting.class_refresh_content",
                      ),
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(FlutterI18n.translate(context, "cancel")),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Future.wait([
                            ClassTableController.i.reloadClassTable(),
                            ExamController.i.reloadExamInfo(),
                            if (!preference.getBool(
                              preference.Preference.role,
                            )) ...[
                              PhysicsExperimentController.i
                                  .reloadPhysicsExperiment(),
                              OtherExperimentController.i
                                  .reloadOtherExperiment(),
                            ],
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
              ListTile(
                leading: const Icon(MingCuteIcons.mgc_delete_2_line),
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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(FlutterI18n.translate(context, "cancel")),
                      ),
                      TextButton(
                        onPressed: () async {
                          await CustomClassController.i.clearAll();
                          if (context.mounted) {
                            setState(() {});
                            showToast(
                              context: context,
                              msg: FlutterI18n.translate(
                                context,
                                "setting.clear_user_class_clear",
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(FlutterI18n.translate(context, "confirm")),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
