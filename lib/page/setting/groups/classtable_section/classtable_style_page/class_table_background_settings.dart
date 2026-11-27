// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'package:watermeter/page/classtable/model/style_config/class_table_background_style_config.dart';
import 'package:watermeter/page/public_widget/setting/setting_section_scaffold.dart';
import 'package:watermeter/page/public_widget/setting/setting_segmented_list.dart';
import 'package:watermeter/page/public_widget/setting/setting_slider_tile.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/pick_file.dart';

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
  static const _maxBackgroundWidth = 2000;

  double _backgroundBlur = ClassTableBackgroundStyleConfig.blur;

  bool get _hasBackground => ClassTableBackgroundStyleConfig.hasImage(
    directory: supportPath,
    fileName: ClassTableController.decorationName,
  );

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
              final optimizedJpeg = await _resizeBackgroundAsJpeg(source);
              await pending.writeAsBytes(optimizedJpeg, flush: true);
              if (await pending.length() == 0) {
                throw FileSystemException("Selected background image is empty");
              }
              await pending.rename(target.path);
              await target.setLastModified(DateTime.now());
            } finally {
              if (await pending.exists()) await pending.delete();
            }

            // The display widgets use FileImage without a ResizeImage wrapper, so this evicts
            // the exact provider key used by both the preview and the live timetable.
            await FileImage(target).evict();
            saved = true;
          }
        }
      } on FileSystemException catch (error, stackTrace) {
        log.handle(
          error,
          stackTrace,
          "[ClassTableBackgroundSettings] Failed to save background image from "
          "${selectedFile.path}",
        );
        saved = false;
      } catch (error, stackTrace) {
        log.handle(
          error,
          stackTrace,
          "[ClassTableBackgroundSettings] Failed to decode or resize background image from "
          "${selectedFile.path}",
        );
        saved = false;
      }
    }

    if (!mounted) return;

    if (!saved) {
      showToast(context: context, msg: context.t.setting.failureSetting);
      return;
    }

    await ClassTableBackgroundStyleConfig.setImageAvailable(true);
    await ClassTableBackgroundStyleConfig.setDecorated(true);
    if (!mounted) return;
    ClassTableBackgroundStyleConfig.notifyImageChanged();
    widget.onChanged();
    showToast(context: context, msg: context.t.setting.successfulSetting);
  }

  Future<Uint8List> _resizeBackgroundAsJpeg(File source) async {
    final sourceBytes = await source.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(sourceBytes);
    final codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (width, height) {
        if (width <= _maxBackgroundWidth) return const ui.TargetImageSize();
        final scale = _maxBackgroundWidth / width;
        return ui.TargetImageSize(
          width: _maxBackgroundWidth,
          height: (height * scale).round().clamp(1, 100000),
        );
      },
    );

    try {
      final frame = await codec.getNextFrame();
      final decoded = frame.image;
      try {
        final rgba = await decoded.toByteData(
          format: ui.ImageByteFormat.rawStraightRgba,
        );
        if (rgba == null) {
          throw const FormatException("Unable to decode background image");
        }

        final pixels = rgba.buffer.asUint8List(
          rgba.offsetInBytes,
          rgba.lengthInBytes,
        );
        final jpegImage = img.Image(
          width: decoded.width,
          height: decoded.height,
          numChannels: 3,
        );
        for (var y = 0; y < decoded.height; y++) {
          for (var x = 0; x < decoded.width; x++) {
            final offset = (y * decoded.width + x) * 4;
            final alpha = pixels[offset + 3] / 255;
            jpegImage.setPixelRgb(
              x,
              y,
              (pixels[offset] * alpha + 255 * (1 - alpha)).round(),
              (pixels[offset + 1] * alpha + 255 * (1 - alpha)).round(),
              (pixels[offset + 2] * alpha + 255 * (1 - alpha)).round(),
            );
          }
        }
        return Uint8List.fromList(img.encodeJpg(jpegImage, quality: 90));
      } finally {
        decoded.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBackgroundOn =
        _hasBackground && ClassTableBackgroundStyleConfig.decorated;
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
              await ClassTableBackgroundStyleConfig.setDecorated(value);
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
                    await ClassTableBackgroundStyleConfig.setBlur(value);
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
