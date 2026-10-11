// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/miscellaneous_session/xidian_sport_session.dart';
import 'package:watermeter/repository/single_flight.dart';

class SportController {
  static final SportController i = SportController._();

  SportController._();

  final SportSession session = SportSession();
  final _classFlight = SingleFlight<FetchResult<SportClass>>();
  final _lastValidClass = signal<FetchResult<SportClass>?>(null);

  final sportClassStateSignal = signal<AsyncState<FetchResult<SportClass>>>(
    const AsyncLoading(),
  );

  late final sportClassesComputedSignal = computed<SportClass>(
    () => _lastValidClass.value?.data ?? const <SportClassItem>[],
  );

  Future<FetchResult<SportClass>> reloadClass() {
    final previous = _lastValidClass.value;
    sportClassStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();

    return _classFlight.run(() async {
      try {
        final result = await session.getClass();
        _lastValidClass.value = result;
        sportClassStateSignal.set(AsyncState.data(result), force: true);
        return result;
      } catch (e, s) {
        sportClassStateSignal.value = AsyncState.error(e, s);
        log.handle(e, s, '[SportController][reloadClass] Have issue');
        rethrow;
      }
    });
  }
}
