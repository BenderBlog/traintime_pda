// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/network_usage.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class SchoolnetController {
  static final SchoolnetController i = SchoolnetController._();
  bool _isReloading = false;

  SchoolnetController._();

  Future<String> Function(List<int>)? _captchaFunction;

  final schoolNetUsageStateSignal =
      signal<AsyncState<FetchResult<GeneralNetworkUsage>>>(
        const AsyncLoading(),
      );

  Future<void> reloadSchoolnetInfo({
    Future<String> Function(List<int>)? captchaFunction,
  }) async {
    log.info("[SchoolnetController] Ready to fetch the schoolnet infos.");
    if (_isReloading) return;
    _isReloading = true;
    _captchaFunction = captchaFunction;
    final previous = schoolNetUsageStateSignal.peek().value;
    schoolNetUsageStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await SchoolnetSession().getGeneralNetworkUsage(
        captchaFunction: _captchaFunction,
      );
      schoolNetUsageStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      schoolNetUsageStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[SchoolnetController][reloadSchoolnetInfo] Have issue");
    } finally {
      _isReloading = false;
    }
  }
}
