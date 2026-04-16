// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class LibraryController {
  static final LibraryController i = LibraryController._();
  bool _isReloading = false;

  LibraryController._();

  final libraryBorrowStateSignal = signal<AsyncState<List<BorrowData>>>(
    const AsyncLoading(),
  );

  Future<void> reloadBorrowList() async {
    if (_isReloading) return;
    _isReloading = true;
    final previous = libraryBorrowStateSignal.peek().value;
    libraryBorrowStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await LibrarySession().getBorrowList();
      libraryBorrowStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      libraryBorrowStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[LibraryController][reloadBorrowList] Have issue");
    } finally {
      _isReloading = false;
    }
  }
}
