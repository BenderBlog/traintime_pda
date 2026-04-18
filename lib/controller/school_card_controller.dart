// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';

class SchoolCardController {
  static final SchoolCardController i = SchoolCardController._();
  bool _isReloading = false;

  SchoolCardController._();

  final moneyStateSignal = signal<AsyncState<String>>(const AsyncLoading());

  Future<void> reloadOverview() async {
    log.info("[SchoolCardController] Ready to fetch school card overview.");
    if (_isReloading) return;
    _isReloading = true;
    final previous = moneyStateSignal.peek().value;
    moneyStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await SchoolCardSession().getOverview();
      moneyStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      moneyStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[SchoolCardController][reloadOverview] Have issue");
    } finally {
      _isReloading = false;
    }
  }
}
