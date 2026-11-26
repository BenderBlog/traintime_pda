// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Connect to the database named 'xdyou_database'
///
/// Due to the responsibility design of the core library,
/// I move the Database entity object to `/lib/integration/database`
/// to avoid the situation that core relies on feature.
QueryExecutor openDatabaseConnection() => driftDatabase(
  name: 'xdyou_database',
  native: DriftNativeOptions(
    setup: (db) => db.execute('PRAGMA foreign_keys = ON'),
  ),
);
