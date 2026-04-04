// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';

class SchoolCardController {
  static final SchoolCardController i = SchoolCardController._();

  SchoolCardController._();

  late final moneySignal = futureSignal<String>(
    () => SchoolCardSession().getOverview(),
    debugLabel: "SchoolCardOverviewSignal",
  );

  Future<void> reloadOverview() async {
    log.info("[SchoolCardController] Ready to fetch school card overview.");
    if (moneySignal.value.isLoading) return;

    try {
      await moneySignal.reload();
    } catch (e, s) {
      log.error(
        "[SchoolCardController] Failed to fetch school card overview.",
        e,
        s,
      );
    }
  }
}
