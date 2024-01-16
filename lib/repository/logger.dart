// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:developer' as developer;
import 'package:logger/logger.dart';

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
    event.lines.forEach(developer.log);
  }
}

var logMemory = MemoryOutput(
  bufferSize: 200,
);

var log = Logger(
  filter: PDALogFilter(),
  printer: SimplePrinter(),
  output: MultiOutput([
    ConsoleOutput(),
    logMemory,
  ]),
);
