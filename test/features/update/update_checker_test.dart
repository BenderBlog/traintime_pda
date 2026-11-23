// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:watermeter/features/update/application/update_checker.dart';

void main() {
  test('classifies a newer, current, and testing version', () {
    expect(compareUpdateVersions('1.3.0', '1.2.9'), UpdateStatus.available);
    expect(compareUpdateVersions('1.2.0', '1.2.0'), UpdateStatus.current);
    expect(compareUpdateVersions('1.1.9', '1.2.0'), UpdateStatus.testing);
  });

  test('publishes the fetched release and preserves errors', () async {
    final repository = _FakeUpdateRepository();
    final checker = UpdateChecker(repository, localVersion: '1.2.0');

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
