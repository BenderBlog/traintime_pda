// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:drift/drift.dart';

part 'database_fixture.g.dart';

class SampleRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
}

@DriftDatabase(tables: [SampleRecords])
class SampleDatabase extends _$SampleDatabase {
  SampleDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
