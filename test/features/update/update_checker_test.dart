// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/logging/talker_app_logger.dart';
import 'package:watermeter/features/update/update_checker.case.dart';

void main() {
  test('records update checks and failures in Talker', () async {
    final talker = Talker(logger: TalkerLogger(output: (_) {}));
    final repository = _FakeUpdateRepository();
    final checker = UpdateChecker(
      repository,
      localVersion: '1.2.0',
      logger: TalkerAppLogger(talker),
    );

    await checker.check();
    repository.fail = true;
    await checker.check();
    final messages = talker.history.map((entry) => entry.message).join('\n');
    expect(messages, contains('available'));
    expect(messages, contains('1.3.0'));
    expect(messages, contains('failed'));
    expect(messages, contains('StateError'));
    checker.dispose();
  });
  test('classifies a newer, current, and testing version', () {
    expect(compareUpdateVersions('1.3.0', '1.2.9'), UpdateStatus.available);
    expect(compareUpdateVersions('1.2.0', '1.2.0'), UpdateStatus.current);
    expect(compareUpdateVersions('1.1.9', '1.2.0'), UpdateStatus.testing);
  });

  test('publishes the fetched release and preserves errors', () async {
    final repository = _FakeUpdateRepository();
    final checker = UpdateChecker(
      repository,
      localVersion: '1.2.0',
      logger: TalkerAppLogger(Talker(logger: TalkerLogger(output: (_) {}))),
    );

    final first = checker.check();
    expect(checker.state.value, isA<UpdateNoticeLoading>());
    await first;
    final ready = checker.state.value as UpdateNoticeReady;
    expect(ready.release.code, '1.3.0');
    expect(ready.status, UpdateStatus.available);

    repository.fail = true;
    expect(await checker.check(), isA<UpdateNoticeFailure>());
    expect(checker.state.value, isA<UpdateNoticeFailure>());
    checker.dispose();
  });
}

class _FakeUpdateRepository implements UpdateRepository {
  bool fail = false;

  @override
  Future<UpdateReleaseData> fetchLatest() async {
    if (fail) throw StateError('network failed');
    return (
      code: '1.3.0',
      changes: ['New timetable'],
      iosUrl: 'https://example.org/ios',
      androidUrl: 'https://example.org/android',
      githubUrl: 'https://example.org/releases',
    );
  }
}
