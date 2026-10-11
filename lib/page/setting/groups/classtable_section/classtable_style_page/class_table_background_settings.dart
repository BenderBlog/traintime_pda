// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ClassTableBackgroundSettings extends StatefulWidget {
  const ClassTableBackgroundSettings({
    super.key,
    required this.onChanged,
    required this.onBlurChanged,
  });

  final VoidCallback onChanged;
  final ValueChanged<double> onBlurChanged;

  @override
  State<ClassTableBackgroundSettings> createState() =>
      _ClassTableBackgroundSettingsState();
}

class _ClassTableBackgroundSettingsState
    extends State<ClassTableBackgroundSettings> {
  static const _imageExtensions = {'.jpg', '.jpeg', '.heic', '.heif', '.png'};

  double _backgroundBlur = preference.getDouble(
    preference.Preference.classTableBackgroundBlur,
  );

  bool get _hasBackground =>
      preference.getBool(preference.Preference.decoration) &&
      File(
        "${supportPath.path}/${ClassTableController.decorationName}",
      ).existsSync();

  Future<void> _chooseBackground() async {
    PlatformFile? selectedFile;
    try {
      selectedFile = await pickFile(type: FileType.image);
    } on MissingStoragePermissionException {
      if (mounted) {
        showToast(context: context, msg: context.t.setting.noPermission);
      }
      return;
    }

    var saved = false;
    if (selectedFile != null) {
      try {
        final path = selectedFile.path;
        if (path != null && path.isNotEmpty) {
          final type = await FileSystemEntity.type(path, followLinks: true);
          File? source;

          if (type == FileSystemEntityType.file) {
            source = File(path);
          } else if (type == FileSystemEntityType.directory) {
            /// iOS may expose a Live Photo as a `.pvt` package directory.
            await for (final entity in Directory(
              path,
            ).list(followLinks: false)) {
              if (entity is! File) continue;
              final lowerPath = entity.path.toLowerCase();
              if (_imageExtensions.any(lowerPath.endsWith)) {
                source = entity;
                break;
              }
            }
          }

          if (source != null) {
            final target = File(
              "${supportPath.path}/${ClassTableController.decorationName}",
            );
            final pending = File("${target.path}.pending");
            try {
              await source.copy(pending.path);
              if (await pending.length() == 0) {
                throw FileSystemException("Selected background image is empty");
              }
              await pending.rename(target.path);
              await target.setLastModified(DateTime.now());
            } finally {
              if (await pending.exists()) await pending.delete();
            }

            // FileImage caches by path. Evict the old decoded image after an
            // atomic replacement so both the preview and timetable reload it.
            await FileImage(target).evict();
            saved = true;
          }
        }
      } on FileSystemException {
        saved = false;
      }
    }

    if (!mounted) return;

    if (!saved) {
      showToast(context: context, msg: context.t.setting.failureSetting);
      return;
    }

    await preference.setBool(preference.Preference.decoration, true);
    await preference.setBool(preference.Preference.decorated, true);
    if (!mounted) return;
    widget.onChanged();
    showToast(context: context, msg: context.t.setting.successfulSetting);
  }

  @override
  Widget build(BuildContext context) {
    bool isBackgroundOn =
        _hasBackground && preference.getBool(preference.Preference.decorated);
    return SectionSettingScaffold(
      icon: Icons.wallpaper,
      title: context.t.setting.classTableBackgroundSection,
      items: SettingSegmentedList(
        items: [
          SwitchListTile(
            secondary: const Icon(MingCuteIcons.mgc_pic_line),
            title: Text(context.t.setting.background),
            value: isBackgroundOn,
            onChanged: (value) async {
              if (value && !_hasBackground) {
                showToast(
                  context: context,
                  msg: context.t.setting.noBackground,
                );
                return;
              }
              await preference.setBool(preference.Preference.decorated, value);
              if (mounted) widget.onChanged();
            },
          ),
          SettingSliderTile(
            leading: Icons.blur_on_sharp,
            title: context.t.setting.editor.backgroundBlur,
            formatValue: (value) => value <= 0
                ? context.t.setting.backgroundBlurOff
                : value.round().toString(),
            value: _backgroundBlur,
            min: 0,
            max: maxClassTableBackgroundBlur,
            divisions: maxClassTableBackgroundBlur.round(),
            onChanged: isBackgroundOn
                ? (value) {
                    _backgroundBlur = value;
                    widget.onBlurChanged(value);
                  }
                : null,
            onChangeEnd: isBackgroundOn
                ? (value) async {
                    await preference.setDouble(
                      preference.Preference.classTableBackgroundBlur,
                      value,
                    );
                    if (!mounted) return;
                    _backgroundBlur = value;
                    widget.onChanged();
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.photo_album_outlined),
            title: Text(context.t.setting.chooseBackground),
            trailing: const Icon(Icons.navigate_next),
            onTap: _chooseBackground,
          ),
        ],
      ),
    );
  }
}
