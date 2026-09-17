// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:time/time.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

enum AirconControl {
  power,
  temperature,
  mode,
  windSpeed,
  verticalSwing,
  strongMode,
  electricHeating,
}

class AirconController {
  static final AirconController i = AirconController._();

  final session = AirconSession();
  final _pendingCommands =
      <
        AirconControl,
        ({int id, AirconState Function(AirconState state) apply})
      >{};
  AirconState? _confirmedDeviceState;
  int _energyRequestId = 0;
  int _deviceRequestId = 0;
  int _nextCommandId = 0;
  int _confirmedCommandId = 0;

  AirconController._() {
    final imei = imeiSignal.peek();
    final cache = session.getCache(imei: imei);
    if (cache != null) {
      _lastValidInfo.value = cache;
      energyInfoStateSignal.value = AsyncState.data(cache);
    }

    energyHistoryInfoList
      ..clear()
      ..addAll(session.getEnergyHistory());

    if (imei.isNotEmpty) {
      Future.microtask(refreshEnergyInfo);
      Future.microtask(refreshDeviceState);
    }
  }

  final imeiSignal = signal<String>(
    preference.getString(preference.Preference.airconImei),
  );
  final _lastValidInfo = signal<FetchResult<AirconEnergyInfo>?>(null);
  final energyInfoStateSignal =
      signal<AsyncState<FetchResult<AirconEnergyInfo>>>(const AsyncLoading());
  final deviceStateSignal = signal<AsyncState<AirconState>>(
    const AsyncLoading(),
  );
  final controllingControlsSignal = signal<Set<AirconControl>>(
    <AirconControl>{},
  );
  final energyHistoryInfoList = <ElectricityHistoryInfo>[];

  static String? tryParseImei(String raw) {
    final matches = RegExp(
      r"\d{15}",
    ).allMatches(raw).map((e) => e.group(0)!).toList();
    if (matches.isEmpty) return null;
    return matches.first;
  }

  static String normalizeImei(String raw) {
    final parsed = tryParseImei(raw.trim());
    if (parsed == null) {
      throw AirconImeiInvalidException(raw);
    }
    return parsed;
  }

  void _syncEnergyHistory(FetchResult<AirconEnergyInfo> info) {
    if (info.isCache) return;

    final newHistoryInfo = List<ElectricityHistoryInfo>.from(
      energyHistoryInfoList,
    );
    final historyInfo = ElectricityHistoryInfo(
      fetchDay: info.data.stateTime,
      remain: info.data.electricAmount.toString(),
    );

    if (newHistoryInfo.isNotEmpty) {
      final last = newHistoryInfo.last;
      if (last.fetchDay.isAtSameDayAs(info.data.stateTime)) {
        if (last.remain == historyInfo.remain) return;

        newHistoryInfo[newHistoryInfo.length - 1] = historyInfo;
        AirconSession.saveEnergyHistory(newHistoryInfo);
        energyHistoryInfoList
          ..clear()
          ..addAll(newHistoryInfo);
        return;
      }
    }

    if (newHistoryInfo.length > 14) {
      newHistoryInfo.removeAt(0);
    }
    newHistoryInfo.add(historyInfo);
    AirconSession.saveEnergyHistory(newHistoryInfo);
    energyHistoryInfoList
      ..clear()
      ..addAll(newHistoryInfo);
  }

  Future<void> refreshEnergyInfo() async {
    final imei = imeiSignal.value;
    if (imei.isEmpty) return;

    final requestId = ++_energyRequestId;
    final previous = _lastValidInfo.value;
    energyInfoStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();

    try {
      final result = await session.getAirconEnergyInfo(imei);
      if (imei != imeiSignal.value || requestId != _energyRequestId) return;
      _lastValidInfo.value = result;
      _syncEnergyHistory(result);
      energyInfoStateSignal.set(AsyncState.data(result), force: true);
    } catch (e, s) {
      if (imei != imeiSignal.value || requestId != _energyRequestId) return;
      energyInfoStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[AirconController][refreshEnergyInfo] Have issue");
    }
  }

  Future<void> refreshDeviceState() async {
    final imei = imeiSignal.value;
    if (imei.isEmpty || _pendingCommands.isNotEmpty) return;
    final requestId = ++_deviceRequestId;
    final requestCommandId = _nextCommandId;

    final previous = _confirmedDeviceState ?? deviceStateSignal.peek().value;
    deviceStateSignal.value = previous == null
        ? const AsyncLoading()
        : AsyncState.dataRefreshing(previous);
    try {
      final state = await session.getDeviceState(imei);
      if (imei != imeiSignal.value ||
          requestId != _deviceRequestId ||
          requestCommandId != _nextCommandId ||
          _pendingCommands.isNotEmpty) {
        return;
      }
      _confirmedDeviceState = state;
      _confirmedCommandId = requestCommandId;
      deviceStateSignal.set(AsyncState.data(state), force: true);
    } catch (e, s) {
      if (imei != imeiSignal.value ||
          requestId != _deviceRequestId ||
          requestCommandId != _nextCommandId ||
          _pendingCommands.isNotEmpty) {
        return;
      }
      deviceStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[AirconController][refreshDeviceState] Have issue");
    }
  }

  Future<void> _sendCommand({
    required AirconControl control,
    required Map<String, dynamic> command,
    required AirconState Function(AirconState state) apply,
  }) async {
    final imei = imeiSignal.value;
    if (imei.isEmpty || _pendingCommands.containsKey(control)) return;

    final commandId = ++_nextCommandId;
    _pendingCommands[control] = (id: commandId, apply: apply);
    controllingControlsSignal.value = _pendingCommands.keys.toSet();
    _publishDeviceState();

    try {
      await session.sendCommand(imei: imei, command: command);
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      final state = await session.getDeviceState(imei);
      if (imei != imeiSignal.value) return;

      if (commandId >= _confirmedCommandId) {
        _confirmedDeviceState = state;
        _confirmedCommandId = commandId;
      }
    } catch (e, s) {
      if (_confirmedDeviceState == null) {
        deviceStateSignal.value = AsyncState.error(e, s);
      }
      log.handle(e, s, "[AirconController][sendCommand] Have issue");
      rethrow;
    } finally {
      if (_pendingCommands[control]?.id == commandId) {
        _pendingCommands.remove(control);
      }
      controllingControlsSignal.value = _pendingCommands.keys.toSet();
      if (imei == imeiSignal.value) _publishDeviceState();
    }
  }

  Future<void> setPower(bool value) => _sendCommand(
    control: AirconControl.power,
    command: value
        ? {"switchStatus": 1}
        : {
            "switchStatus": 0,
            "indoorClean": 0,
            "outdoorClean": 0,
            "electricHeating": 0,
          },
    apply: (state) => state.copyWith(
      isOn: value,
      electricHeating: value ? state.electricHeating : false,
    ),
  );

  Future<void> setTemperature(int value) => _sendCommand(
    control: AirconControl.temperature,
    command: {"tempSet": value},
    apply: (state) => state.copyWith(targetTemperature: value),
  );

  Future<void> setMode(AirconMode mode) {
    final temperature = switch (mode) {
      AirconMode.heat => 23,
      AirconMode.cool => 26,
      _ => 25,
    };
    final windSpeed = mode == AirconMode.fan
        ? AirconWindSpeed.medium
        : AirconWindSpeed.auto;

    return _sendCommand(
      control: AirconControl.mode,
      command: {
        "runMode": mode.value.toString(),
        "indoorClean": 0,
        "outdoorClean": 0,
        "strongMode": 0,
        "electricHeating": 0,
        "tempView": temperature,
        "tempSet": temperature,
        "windSpeed": windSpeed.value,
      },
      apply: (state) => state.copyWith(
        mode: mode,
        targetTemperature: temperature,
        windSpeed: windSpeed,
        strongMode: false,
        electricHeating: false,
      ),
    );
  }

  Future<void> setWindSpeed(AirconWindSpeed value) => _sendCommand(
    control: AirconControl.windSpeed,
    command: {"windSpeed": value.value.toString(), "strongMode": 0},
    apply: (state) => state.copyWith(windSpeed: value, strongMode: false),
  );

  Future<void> setVerticalSwing(bool value) => _sendCommand(
    control: AirconControl.verticalSwing,
    command: {"verticalSwing": value ? 1 : 0},
    apply: (state) => state.copyWith(verticalSwing: value),
  );

  Future<void> setStrongMode(bool value) => _sendCommand(
    control: AirconControl.strongMode,
    command: {
      "strongMode": value ? 1 : 0,
      if (value) "windSpeed": AirconWindSpeed.auto.value,
    },
    apply: (state) => state.copyWith(
      strongMode: value,
      windSpeed: value ? AirconWindSpeed.auto : state.windSpeed,
    ),
  );

  Future<void> setElectricHeating(bool value) => _sendCommand(
    control: AirconControl.electricHeating,
    command: {"electricHeating": value ? 1 : 0},
    apply: (state) => state.copyWith(electricHeating: value),
  );

  void _publishDeviceState() {
    if (_confirmedDeviceState == null) return;
    var state = _confirmedDeviceState!;
    for (final command in _pendingCommands.values) {
      if (command.id > _confirmedCommandId) {
        state = command.apply(state);
      }
    }
    deviceStateSignal.set(AsyncState.data(state), force: true);
  }

  Future<void> updateImei(String rawImei) async {
    final trimmed = rawImei.trim();
    if (trimmed.isEmpty) {
      await clearImei();
      return;
    }

    final imei = normalizeImei(trimmed);
    if (imeiSignal.value != imei) {
      session.clearCache();
      AirconSession.clearEnergyHistory();
      energyHistoryInfoList.clear();
      _lastValidInfo.value = null;
      _energyRequestId++;
      _deviceRequestId++;
      _nextCommandId++;
      _confirmedCommandId = _nextCommandId;
      _confirmedDeviceState = null;
      _pendingCommands.clear();
      controllingControlsSignal.value = <AirconControl>{};
      deviceStateSignal.value = const AsyncLoading();
    }
    await preference.setString(preference.Preference.airconImei, imei);
    imeiSignal.value = imei;
    await refreshEnergyInfo();
    await refreshDeviceState();
  }

  Future<void> clearImei() async {
    await preference.remove(preference.Preference.airconImei);
    imeiSignal.value = "";
    _lastValidInfo.value = null;
    energyInfoStateSignal.value = const AsyncLoading();
    deviceStateSignal.value = const AsyncLoading();
    _energyRequestId++;
    _deviceRequestId++;
    _nextCommandId++;
    _confirmedCommandId = _nextCommandId;
    _confirmedDeviceState = null;
    _pendingCommands.clear();
    controllingControlsSignal.value = <AirconControl>{};
    session.clearCache();
    AirconSession.clearEnergyHistory();
    energyHistoryInfoList.clear();
  }
}

class AirconImeiInvalidException implements Exception {
  final String raw;

  const AirconImeiInvalidException(this.raw);

  @override
  String toString() => "Invalid aircon IMEI: $raw";
}
