// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

final libraryBorrowSignal = futureSignal<List<BorrowData>>(
  () => LibrarySession().getBorrowList(),
  debugLabel: "LibraryBorrowSignal",
);

Future<void> refreshBorrowList() async {
  if (libraryBorrowSignal.value.isLoading) return;
  try {
    await libraryBorrowSignal.reload();
  } catch (_) {}
}
