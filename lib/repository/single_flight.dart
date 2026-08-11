// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

/// Coalesces concurrent calls into one in-flight asynchronous operation.
///
/// The completed result is not cached. A later call starts a new operation.
final class SingleFlight<T> {
  Future<T>? _inFlight;

  Future<T> run(FutureOr<T> Function() action) {
    final running = _inFlight;
    if (running != null) return running;

    late final Future<T> future;
    future = Future<T>.sync(action).whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
    _inFlight = future;
    return future;
  }

  bool get isRunning => _inFlight != null;
}
