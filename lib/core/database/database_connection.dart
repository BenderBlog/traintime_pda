// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Connect to the database named 'xdyou_database'
QueryExecutor openDatabaseConnection() => driftDatabase(
  name: 'xdyou_database',
  native: DriftNativeOptions(
    setup: (db) => db.execute('PRAGMA foreign_keys = ON'),
  ),
);
