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
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/class_table_style_page.dart';
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

  static const _backgroundImageExtensions = <String>{
    '.jpg',
    '.jpeg',
    '.heic',
    '.heif',
    '.png',
  };

  /// iOS may expose a Live Photo as a `.pvt` package directory.
  Future<File?> _resolvePickedBackground(PlatformFile result) async {
    final path = result.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    final type = await FileSystemEntity.type(path, followLinks: true);
    if (type == FileSystemEntityType.file) {
      return File(path);
    }
    if (type != FileSystemEntityType.directory) {
      return null;
    }

    await for (final entity in Directory(path).list(followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final lowerPath = entity.path.toLowerCase();
      if (_backgroundImageExtensions.any(lowerPath.endsWith)) {
        return entity;
      }
    }
    return null;
  }

  Future<bool> _saveBackground(PlatformFile result) async {
    try {
      final source = await _resolvePickedBackground(result);
      if (source == null) {
        return false;
      }

      await source.copy(
        "${supportPath.path}/${ClassTableController.decorationName}",
      );
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Whether a background image is set at all.
  bool get _hasBackground =>
      preference.getBool(preference.Preference.decoration);

  /// The blur which is being dragged. It is mirrored here because the preference
  /// store is written asynchronously: without it the slider would not move
  /// under the finger.
  double _backgroundBlur = preference.getDouble(
    preference.Preference.classTableBackgroundBlur,
  );

  void _previewBackgroundBlur(double value) {
    setState(() => _backgroundBlur = value);
  }

  Future<void> _saveBackgroundBlur(double value) async {
    await preference.setDouble(
      preference.Preference.classTableBackgroundBlur,
      value,
    );
    if (mounted) {
      setState(() => _backgroundBlur = value);
    }
  }

  String _backgroundBlurLabel(BuildContext context) => _backgroundBlur <= 0
      ? FlutterI18n.translate(context, "setting.background_blur_off")
      : _backgroundBlur.round().toString();

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
              if (value == true && !_hasBackground) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(context, "setting.no_background"),
                );
                return;
              }

              preference.setBool(preference.Preference.decorated, value).then((
                _,
              ) {
                if (mounted) {
                  setState(() {});
                }
              });
            },
          ),
        ),
        ListTile(
          title: Text(
            FlutterI18n.translate(
              context,
              "setting.background_blur",
              translationParams: {"value": _backgroundBlurLabel(context)},
            ),
          ),
          subtitle: Slider(
            value: _backgroundBlur.clamp(0.0, maxClassTableBackgroundBlur),
            min: 0,
            max: maxClassTableBackgroundBlur,
            divisions: maxClassTableBackgroundBlur.round(),
            onChanged: _hasBackground ? _previewBackgroundBlur : null,
            onChangeEnd: _hasBackground
                ? (value) => _saveBackgroundBlur(value)
                : null,
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
              final selectedFile = result;
              final saved =
                  selectedFile != null && await _saveBackground(selectedFile);
              if (saved) {
                await preference.setBool(
                  preference.Preference.decoration,
                  true,
                );

                /// Choosing an image is the obvious way of switching the
                /// background on, so turn it on here instead of asking the user
                /// to flip the switch afterwards.
                await preference.setBool(preference.Preference.decorated, true);
                if (mounted) {
                  setState(() {});
                }
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
            FlutterI18n.translate(context, "setting.class_table_style_setting"),
          ),
          subtitle: Text(
            FlutterI18n.translate(
              context,
              "setting.class_table_style_description",
            ),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            context.push(const ClassTableStylePage());
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
                      if (!preference.getBool(preference.Preference.role)) ...[
                        PhysicsExperimentController.i.reloadPhysicsExperiment(),
                        OtherExperimentController.i.reloadOtherExperiment(),
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
