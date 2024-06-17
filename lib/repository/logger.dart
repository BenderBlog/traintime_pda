// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:developer' as developer;
import 'package:alice/alice.dart';
import 'package:catcher/catcher.dart';
import 'package:logger/logger.dart';
import 'package:watermeter/repository/network_session.dart';

/// Prints all logs with `level >= Logger.level` while in development mode (eg
/// when `assert`s are evaluated, Flutter calls this debug mode).
///
/// In release mode all logs BELOW WARNING are omitted.
class PDALogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    var shouldLog = false;
    if (event.level.value > Level.debug.value) {
      shouldLog = true;
    }
    assert(() {
      if (event.level.value >= level!.value) {
        shouldLog = true;
      }
      return true;
    }());
    return shouldLog;
  }
}

/// Default implementation of [LogOutput].
///
/// It sends everything to the system console.
class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var str in event.lines) {
      developer.log(str);
      alice.addLog(AliceLog(
        message: str,
        timestamp: event.origin.time,
      ));
    }
  }
}

var logMemory = MemoryOutput(
  bufferSize: 200,
);

var log = Logger(
  filter: PDALogFilter(),
  printer: LogfmtPrinter(),
  output: ConsoleOutput(),
);

class PDACatcherLogger extends CatcherLogger {
  @override
  void info(String message) {
    log.i('Custom Catcher Logger | Info | $message');
  }

  @override
  void fine(String message) {
    log.i('Custom Catcher Logger | Fine | $message');
  }

  @override
  void warning(String message) {
    log.w('Custom Catcher Logger | Warning | $message');
  }

  @override
  void severe(String message) {
    log.e('Custom Catcher Logger | Servere | $message');
  }
}
