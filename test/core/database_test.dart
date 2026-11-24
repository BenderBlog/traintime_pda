// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/integration/database/xdyou_database.dart';

import 'fixtures/database/database_fixture.dart';

void main() {
  test('database opens with foreign keys and reopens after close', () async {
    final root = Directory.systemTemp.createTempSync('xdyou-db-');
    addTearDown(() => root.deleteSync(recursive: true));
    final file = File('${root.path}/database.sqlite');
    for (var i = 0; i < 2; i++) {
      final database = XDYouDatabase(
        NativeDatabase.createInBackground(
          file,
          setup: (db) => db.execute('PRAGMA foreign_keys = ON'),
        ),
      );
      expect(
        (await database.customSelect('PRAGMA foreign_keys').getSingle())
            .read<int>('foreign_keys'),
        1,
      );
      await database.close();
    }
  });

  test('Drift creates a registered table on first open', () async {
    final database = SampleDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.sampleRecords)
        .insert(SampleRecordsCompanion.insert());
    expect(await database.select(database.sampleRecords).get(), hasLength(1));
  });
}
