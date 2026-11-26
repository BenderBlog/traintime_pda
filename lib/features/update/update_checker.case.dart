// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

import 'package:pda_repository/pda_repository.dart';
import 'package:signals/signals.dart';
import 'package:watermeter/core/logging/logger_interface.dart';

import 'update_release.model.dart';

enum UpdateStatus { available, current, testing }

sealed class UpdateNoticeState {
  const UpdateNoticeState();
}

final class UpdateNoticeLoading extends UpdateNoticeState {
  const UpdateNoticeLoading([this.previous]);

  final UpdateNoticeReady? previous;
}

final class UpdateNoticeReady extends UpdateNoticeState {
  const UpdateNoticeReady(this.release, this.status);

  final UpdateRelease release;
  final UpdateStatus status;
}

final class UpdateNoticeFailure extends UpdateNoticeState {
  const UpdateNoticeFailure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

abstract interface class UpdateNotices {
  ReadonlySignal<UpdateNoticeState> get state;
  Future<UpdateNoticeState> check();
}

UpdateStatus compareUpdateVersions(String remote, String local) {
  final remoteParts = remote.split('.').map(int.parse).toList();
  final localParts = local.split('.').map(int.parse).toList();
  for (var i = 0; i < math.min(remoteParts.length, localParts.length); i++) {
    if (remoteParts[i] > localParts[i]) return UpdateStatus.available;
    if (remoteParts[i] < localParts[i]) return UpdateStatus.testing;
  }
  return UpdateStatus.current;
}

final class UpdateChecker implements UpdateNotices {
  UpdateChecker(
    this._repository, {
    required this.localVersion,
    required this.logger,
  });

  final UpdateRepository _repository;
  final String localVersion;
  final LoggerInterface logger;
  final Signal<UpdateNoticeState> _state = signal(const UpdateNoticeLoading());
  Future<UpdateNoticeState>? _flight;
  bool _disposed = false;

  @override
  ReadonlySignal<UpdateNoticeState> get state => _state.readonly();

  void _publish(UpdateNoticeState next) {
    if (_disposed) return;
    _state.value = next;
  }

  @override
  Future<UpdateNoticeState> check() =>
      _flight ??= _check().whenComplete(() => _flight = null);

  Future<UpdateNoticeState> _check() async {
    logger.info('[Update] check started');
    final previous = switch (_state.peek()) {
      UpdateNoticeReady ready => ready,
      UpdateNoticeLoading(:final previous) => previous,
      UpdateNoticeFailure() => null,
    };
    _publish(UpdateNoticeLoading(previous));
    try {
      final data = await _repository.fetchLatest();
      final release = UpdateRelease(
        code: data.code,
        changes: data.changes,
        iosUrl: data.iosUrl,
        androidUrl: data.androidUrl,
        githubUrl: data.githubUrl,
      );
      final result = UpdateNoticeReady(
        release,
        compareUpdateVersions(release.code, localVersion),
      );
      logger.info(
        '[Update] check completed: ${result.status.name}, local $localVersion, latest ${release.code}',
      );
      _publish(result);
      return result;
    } catch (error, stackTrace) {
      logger.error(
        '[Update] check failed: ${error.runtimeType}',
        null,
        stackTrace,
      );
      final result = UpdateNoticeFailure(error, stackTrace);
      _publish(result);
      return result;
    }
  }

  void dispose() {
    _disposed = true;
    _state.dispose();
  }
}
