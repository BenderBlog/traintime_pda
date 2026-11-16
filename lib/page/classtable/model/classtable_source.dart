// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/classtable/model/classtable_snapshot.dart';

/// Everything the class table needs from the outside world.
///
/// The page, its state and its widgets depend on this only; which implementation answers it — the
/// live school data, or the settings page's sample table — is decided where the page is built. Only
/// the three reads and [dispose] are required: the writes have no sane default, so a source that
/// does not implement them throws instead of silently doing nothing.
///
/// Implementations must expose plain Dart types. A `signal` must not leak through here, or the
/// decoupling would only be on paper.
abstract class ClasstableDataSource {
  /// The data the table draws, republished whenever any of it changes.
  ValueListenable<ClasstableSnapshot> get snapshot;

  /// The clock the table follows.
  ValueListenable<DateTime> get now;

  /// File name of the user's decoration picture.
  String get decorationFileName;

  /// Refreshes every source the current user is allowed to see.
  Future<void> refresh() async {}

  Future<void> addCustomClass(CustomClass customClass) => _readOnly();

  Future<void> editCustomClassById(
    String customClassId,
    CustomClass customClass,
  ) => _readOnly();

  Future<void> deleteCustomClassById(String customClassId) => _readOnly();

  Future<void> deleteCustomClassTimeRange({
    required String customClassId,
    required String timeRangeId,
  }) => _readOnly();

  /// Fresh ids for a new custom class, and for one of its time ranges.
  String newCustomClassId() => _readOnly();

  String newTimeRangeId() => _readOnly();

  void dispose();

  Never _readOnly() =>
      throw UnsupportedError("This class table source is read only.");
}
