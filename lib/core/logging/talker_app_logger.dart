// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/logging/logger_interface.dart';

final class TalkerAppLogger implements LoggerInterface {
  const TalkerAppLogger(this.talker);

  final Talker talker;

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) =>
      talker.debug(message, error, stackTrace);

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) =>
      talker.info(message, error, stackTrace);

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      talker.warning(message, error, stackTrace);

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      talker.error(message, error, stackTrace);
}
