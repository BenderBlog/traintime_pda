// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Ref. https://github.com/acterglobal/a3/pull/2183/
// Must detect permission...

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<FilePickerResult?> pickFile({
  FileType type = FileType.any,
}) async {
  if (Platform.isAndroid) {
    // On Android 8-10 we must be sure to query for the `storage` permission
    // before engaging an image-based file-picker
    // see https://github.com/miguelpruivo/flutter_file_picker/issues/1461
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 29) {
      if (!(await Permission.storage.request().isGranted)) {
        throw MissingStoragePermissionException();
      }
    }
  }
  // Ref. https://github.com/miguelpruivo/flutter_file_picker/issues/1584
  // Disable compression:P
  return await FilePicker.platform.pickFiles(
    type: type,
    compressionQuality: 0,
    allowMultiple: false,
  );
}

class MissingStoragePermissionException implements Exception {}
