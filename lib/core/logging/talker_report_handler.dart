// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:catcher_2/catcher_2.dart';
import 'package:watermeter/core/logging/logger_interface.dart';

final class PDACatcher2Logger extends Catcher2Logger {
  PDACatcher2Logger(this._logger);

  final LoggerInterface _logger;

  @override
  void info(String message) {
    _logger.info('[Catcher2 Logger] <Info> $message');
  }

  @override
  void fine(String message) {
    _logger.info('[Catcher2 Logger] <Fine> $message');
  }

  @override
  void warning(String message) {
    _logger.warning('[Custom Catcher2 Logger] <Warning> $message');
  }

  @override
  void severe(String message) {
    _logger.error('[Custom Catcher2 Logger] <Severe> $message');
  }
}
