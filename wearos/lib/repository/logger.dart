// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

final log = TalkerFlutter.init();
final logDioAdapter = TalkerDioLogger(
  talker: log,
  settings: TalkerDioLoggerSettings(
    printRequestHeaders: true,
    printResponseHeaders: true,
    printResponseMessage: true,
    responseFilter: (response) {
      // 1. 忽略特定 URL
      final url = response.requestOptions.uri.toString();
      if (url.contains('openSliderCaptcha.htl')) {
        return false;
      }

      // 2. 忽略二进制文件 (Uint8List)
      // 通常通过检查 response.data 的类型或 Content-Type 头部
      if (response.data is List<int> || response.data is Uint8List) {
        return false;
      }

      return true;
    },
  ),
);
