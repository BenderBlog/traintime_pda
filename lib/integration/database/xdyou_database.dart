// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:drift/drift.dart';

import 'package:watermeter/core/database/database_connection.dart';

part 'xdyou_database.g.dart';

@DriftDatabase(tables: [])
class XDYouDatabase extends _$XDYouDatabase {
  XDYouDatabase([QueryExecutor? executor])
    : super(executor ?? openDatabaseConnection());

  @override
  int get schemaVersion => 1;
}
