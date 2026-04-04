// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class LibraryController {
  static final LibraryController i = LibraryController._();

  LibraryController._();

  final libraryBorrowSignal = futureSignal<List<BorrowData>>(
    () => LibrarySession().getBorrowList(),
    debugLabel: "LibraryBorrowSignal",
  );

  Future<void> reloadBorrowList() async {
    if (libraryBorrowSignal.value.isLoading) return;
    return await libraryBorrowSignal.reload().then(
      (value) {},
      onError: (e, s) =>
          log.handle(e, s, "[LibraryController][reloadBorrowList] Have issue."),
    );
  }
}
