// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/xidian_ids/network_usage.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class SchoolnetController {
  static final SchoolnetController i = SchoolnetController._();

  SchoolnetController._();

  Future<String> Function(List<int>)? _captchaFunction;

  late final schoolNetUsageSignal = futureSignal<GeneralNetworkUsage>(
    () => SchoolnetSession().getGeneralNetworkUsage(
      captchaFunction: _captchaFunction,
    ),
    debugLabel: "SchoolNetUsageSignal",
  );

  Future<void> reloadSchoolnetInfo({
    Future<String> Function(List<int>)? captchaFunction,
  }) async {
    log.info("[SchoolnetController] Ready to fetch the schoolnet infos.");
    if (schoolNetUsageSignal.value.isLoading) return;

    _captchaFunction = captchaFunction;
    await schoolNetUsageSignal.reload().catchError(
      (e, s) => log.handle(
        e,
        s,
        "[SchoolnetController][reloadSchoolnetInfo] Have issue",
      ),
    );
  }
}
