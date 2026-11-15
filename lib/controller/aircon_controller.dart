// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/model/aircon_energy.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AirconController {
  static final AirconController i = AirconController._();

  final session = AirconSession();
  bool _isEnergyReloading = false;
  bool _isDeviceReloading = false;

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
      // Future.microtask(refreshEnergyInfo);
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

  Future<void> refreshEnergyInfo() async {
    final imei = imeiSignal.value;
    if (imei.isEmpty || _isEnergyReloading) return;

    _isEnergyReloading = true;
    final previous = _lastValidInfo.value;
    energyInfoStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();

    try {
      final result = await session.getAirconEnergyInfo(imei);
      if (imei != imeiSignal.value) return;
      _lastValidInfo.value = result;
      // _syncEnergyHistory(result);
      energyInfoStateSignal.set(AsyncState.data(result), force: true);
    } catch (e, s) {
      if (imei != imeiSignal.value) return;
      energyInfoStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[AirconController][refreshEnergyInfo] Have issue");
    } finally {
      _isEnergyReloading = false;
      if (imeiSignal.value.isNotEmpty && imei != imeiSignal.value) {
        Future.microtask(refreshEnergyInfo);
      }
    }
  }

  Future<void> refreshDeviceState() async {
    final imei = imeiSignal.value;
    if (imei.isEmpty || _isDeviceReloading) return;

    _isDeviceReloading = true;
    final previous = deviceStateSignal.peek().value;
    deviceStateSignal.value = previous == null
        ? const AsyncLoading()
        : AsyncState.dataRefreshing(previous);
    try {
      final state = await session.getDeviceState(imei);
      if (imei != imeiSignal.value) return;
      deviceStateSignal.set(AsyncState.data(state), force: true);
    } catch (e, s) {
      if (imei != imeiSignal.value) return;
      deviceStateSignal.value = AsyncState.error(e, s);
      log.handle(e, s, "[AirconController][refreshDeviceState] Have issue");
    } finally {
      _isDeviceReloading = false;
      if (imeiSignal.value.isNotEmpty && imei != imeiSignal.value) {
        Future.microtask(refreshDeviceState);
      }
    }
  }

  /// 构造电源指令；关机时同时关闭清洁和辅助电热。
  AirconRemoteCommand powerCommand(AirconState state, bool value) =>
      AirconRemoteCommand(
        parameters: value
            ? {"switchStatus": 1}
            : {
                "switchStatus": 0,
                "indoorClean": 0,
                "outdoorClean": 0,
                "electricHeating": 0,
              },
        optimisticState: state.copyWith(
          isOn: value,
          electricHeating: value ? state.electricHeating : false,
        ),
        matches: (state) => state.isOn == value,
      );

  /// 构造目标温度指令；超出设备范围时拒绝下发。
  AirconRemoteCommand temperatureCommand(AirconState state, int value) {
    if (value < minTemperature || value > maxTemperature) {
      throw RangeError.range(
        value,
        minTemperature,
        maxTemperature,
        'temperature',
      );
    }
    return AirconRemoteCommand(
      parameters: {"tempSet": value},
      optimisticState: state.copyWith(targetTemperature: value),
      matches: (state) => state.targetTemperature == value,
    );
  }

  /// 构造模式切换指令，并按设备规则重置温度、风速和其他功能。
  AirconRemoteCommand? modeCommand(AirconState state, AirconMode mode) {
    if (mode == state.mode) return null;
    final temperature = switch (mode) {
      AirconMode.heat => 23,
      AirconMode.cool => 26,
      _ => 25,
    };
    final windSpeed = mode == AirconMode.fan
        ? AirconWindSpeed.medium
        : AirconWindSpeed.auto;
    return AirconRemoteCommand(
      parameters: {
        "runMode": mode.value.toString(),
        "indoorClean": 0,
        "outdoorClean": 0,
        "strongMode": 0,
        "electricHeating": 0,
        "tempView": temperature,
        "tempSet": temperature,
        "windSpeed": windSpeed.value,
      },
      optimisticState: state.copyWith(
        mode: mode,
        targetTemperature: temperature,
        windSpeed: windSpeed,
        strongMode: false,
        electricHeating: false,
      ),
      matches: (state) =>
          state.mode == mode &&
          state.targetTemperature == temperature &&
          state.windSpeed == windSpeed &&
          !state.strongMode &&
          !state.electricHeating,
    );
  }

  /// 构造风速指令；改变风速时退出强力模式。
  AirconRemoteCommand? windSpeedCommand(
    AirconState state,
    AirconWindSpeed speed,
  ) {
    if (speed == state.windSpeed && !state.strongMode) return null;
    return AirconRemoteCommand(
      parameters: {"windSpeed": speed.value.toString(), "strongMode": 0},
      optimisticState: state.copyWith(windSpeed: speed, strongMode: false),
      matches: (state) => state.windSpeed == speed && !state.strongMode,
    );
  }

  /// 构造上下扫风指令。
  AirconRemoteCommand verticalSwingCommand(AirconState state, bool value) =>
      AirconRemoteCommand(
        parameters: {"verticalSwing": value ? 1 : 0},
        optimisticState: state.copyWith(verticalSwing: value),
        matches: (state) => state.verticalSwing == value,
      );

  /// 构造强力模式指令；启用时同时切换为自动风速。
  AirconRemoteCommand strongModeCommand(AirconState state, bool value) =>
      AirconRemoteCommand(
        parameters: {
          "strongMode": value ? 1 : 0,
          if (value) "windSpeed": AirconWindSpeed.auto.value,
        },
        optimisticState: state.copyWith(
          strongMode: value,
          windSpeed: value ? AirconWindSpeed.auto : state.windSpeed,
        ),
        matches: (state) =>
            state.strongMode == value &&
            (!value || state.windSpeed == AirconWindSpeed.auto),
      );

  /// 构造辅助电热指令。
  AirconRemoteCommand electricHeatingCommand(AirconState state, bool value) =>
      AirconRemoteCommand(
        parameters: {"electricHeating": value ? 1 : 0},
        optimisticState: state.copyWith(electricHeating: value),
        matches: (state) => state.electricHeating == value,
      );

  /// 下发指令并轮询确认；页面离开或设备变化时不再处理过期结果。
  Future<AirconState?> sendRemoteCommand({
    required String imei,
    required AirconRemoteCommand command,
    required bool Function() isCurrent,
  }) async {
    var sent = false;
    try {
      await session.sendCommand(imei: imei, command: command.parameters);
      sent = true;
      Object? pollError;
      for (var attempt = 0; attempt < 12; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        }
        if (!isCurrent() || imei != imeiSignal.value) return null;
        try {
          final state = await session.getDeviceState(imei);
          if (!isCurrent() || imei != imeiSignal.value) return null;
          if (state.imei == imei && command.matches(state)) return state;
        } catch (error) {
          pollError = error;
        }
      }
      if (!isCurrent() || imei != imeiSignal.value) return null;
      throw pollError ??
          const AirconResponseException("device state unconfirmed");
    } catch (error) {
      throw AirconCommandException(error, sent: sent);
    }
  }

  void setDeviceState(AirconState state) {
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
      deviceStateSignal.value = const AsyncLoading();
    }
    await preference.setString(preference.Preference.airconImei, imei);
    imeiSignal.value = imei;
    // await refreshEnergyInfo();
    await refreshDeviceState();
  }

  Future<void> clearImei() async {
    await preference.remove(preference.Preference.airconImei);
    imeiSignal.value = "";
    _lastValidInfo.value = null;
    energyInfoStateSignal.value = const AsyncLoading();
    deviceStateSignal.value = const AsyncLoading();
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
