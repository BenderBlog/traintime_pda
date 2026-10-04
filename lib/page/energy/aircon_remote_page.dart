// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// 米家风格的空调遥控页，沿用原有指令和状态确认逻辑。

import 'package:flutter/services.dart';
import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/aircon_imei_page.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';

/// 温度的可调范围，和设备本身一致。
const _minTemperature = 18;
const _maxTemperature = 32;
const _stateMotionDuration = Duration(milliseconds: 260);
const _pressMotionDuration = Duration(milliseconds: 120);

class AirconRemotePage extends StatefulWidget {
  const AirconRemotePage({super.key});

  @override
  State<AirconRemotePage> createState() => _AirconRemotePageState();
}

class _AirconRemotePageState extends State<AirconRemotePage> {
  final _controller = AirconController.i;
  AirconState? _state;
  Object? _error;
  bool _isFetching = false;
  bool Function(AirconState state)? _pendingMatches;
  int _generation = 0;
  late String _lastImei;
  late final void Function() _disposeImeiEffect;

  static const _pollInterval = Duration(milliseconds: 300);
  static const _pollAttempts = 12;

  @override
  void initState() {
    super.initState();
    _lastImei = _controller.imeiSignal.peek();
    _state = _controller.deviceStateSignal.peek().value;
    _disposeImeiEffect = effect(() {
      final imei = _controller.imeiSignal.value;
      if (imei == _lastImei) return;
      _lastImei = imei;
      _generation++;
      if (!mounted) return;
      setState(() {
        _state = null;
        _error = null;
        _pendingMatches = null;
        _isFetching = false;
      });
      if (imei.isNotEmpty) Future.microtask(_refreshDeviceState);
    });
    Future.microtask(_refreshDeviceState);
  }

  @override
  void dispose() {
    _disposeImeiEffect();
    super.dispose();
  }

  Future<void> _configure() async {
    await context.push<void>(const AirconImeiPage());
    if (!mounted) return;
    _generation++;
    setState(() {
      _state = null;
      _error = null;
      _pendingMatches = null;
      _isFetching = false;
    });
    await _refreshDeviceState();
  }

  Future<void> _refreshDeviceState() async {
    final imei = _controller.imeiSignal.value;
    if (imei.isEmpty || _isFetching) return;
    final generation = ++_generation;

    setState(() {
      _isFetching = true;
      _error = null;
    });

    try {
      final state = await _controller.session.getDeviceState(imei);
      if (!mounted) return;
      if (generation != _generation) return;
      if (imei != _controller.imeiSignal.value) {
        setState(() {
          _isFetching = false;
          _pendingMatches = null;
        });
        return;
      }
      if (state.imei != imei) {
        throw const AirconResponseException("设备状态归属不匹配");
      }

      final matches = _pendingMatches;
      if (matches != null && !matches(state)) {
        setState(() {
          _error = const AirconResponseException("设备状态仍未确认");
          _isFetching = false;

          // 确认失败后解除待确认状态，让控件恢复可用。
          _pendingMatches = null;
        });
        return;
      }

      setState(() {
        _state = state;
        _error = null;
        _isFetching = false;
        _pendingMatches = null;
      });
      _controller.setDeviceState(state);
    } catch (error) {
      if (!mounted) return;
      if (generation != _generation) return;
      if (imei != _controller.imeiSignal.value) {
        setState(() {
          _isFetching = false;
          _pendingMatches = null;
        });
        return;
      }
      setState(() {
        _error = error;
        _isFetching = false;
        _pendingMatches = null;
      });
    }
  }

  Future<void> _sendCommand({
    required Map<String, dynamic> command,
    required AirconState optimisticState,
    required bool Function(AirconState state) matches,
  }) async {
    final imei = _controller.imeiSignal.value;
    final previous = _state;
    if (imei.isEmpty ||
        previous == null ||
        _pendingMatches != null ||
        _isFetching) {
      return;
    }
    final generation = ++_generation;

    HapticFeedback.selectionClick();
    setState(() {
      _state = optimisticState;
      _error = null;
      _isFetching = true;
      _pendingMatches = matches;
    });

    var commandSent = false;
    try {
      await _controller.session.sendCommand(imei: imei, command: command);
      commandSent = true;
      AirconState? confirmedState;
      Object? pollError;

      for (var attempt = 0; attempt < _pollAttempts; attempt++) {
        if (attempt > 0) await Future<void>.delayed(_pollInterval);
        if (!mounted) return;
        if (generation != _generation) return;
        if (imei != _controller.imeiSignal.value) {
          setState(() {
            _isFetching = false;
            _pendingMatches = null;
          });
          return;
        }

        try {
          final state = await _controller.session.getDeviceState(imei);
          if (!mounted) return;
          if (generation != _generation) return;
          if (imei != _controller.imeiSignal.value) {
            setState(() {
              _isFetching = false;
              _pendingMatches = null;
            });
            return;
          }
          if (state.imei == imei && matches(state)) {
            confirmedState = state;
            break;
          }
        } catch (error) {
          pollError = error;
        }
      }

      if (!mounted) return;
      if (generation != _generation) return;
      if (imei != _controller.imeiSignal.value) {
        setState(() {
          _isFetching = false;
          _pendingMatches = null;
        });
        return;
      }
      if (confirmedState == null) {
        throw pollError ?? const AirconResponseException("设备状态未确认");
      }

      setState(() {
        _state = confirmedState;
        _error = null;
        _isFetching = false;
        _pendingMatches = null;
      });
      _controller.setDeviceState(confirmedState);
      showToast(context: context, msg: context.t.electricity.airconCommandOk);
    } catch (error) {
      if (!mounted) return;
      if (generation != _generation) return;
      if (imei != _controller.imeiSignal.value) {
        setState(() {
          _isFetching = false;
          _pendingMatches = null;
        });
        return;
      }
      setState(() {
        _error = error;
        _isFetching = false;

        // 失败后解除待确认状态，仅在指令未发送时恢复旧状态。
        _pendingMatches = null;
        if (!commandSent) {
          _state = previous;
        }
      });
      showToast(context: context, msg: error.toString());
    }
  }

  // --- 各个控件的下发 ---

  void _setPower(AirconState state, bool value) => _sendCommand(
    command: value
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

  void _setTemperature(AirconState state, int value) {
    if (value < _minTemperature || value > _maxTemperature) {
      showToast(
        context: context,
        msg: context.t.electricity.airconTemperatureRange,
      );
      return;
    }
    _sendCommand(
      command: {"tempSet": value},
      optimisticState: state.copyWith(targetTemperature: value),
      matches: (state) => state.targetTemperature == value,
    );
  }

  void _setMode(AirconState state, AirconMode mode) {
    if (mode == state.mode) return;

    // 切换模式时同步设备默认温度和风速，供轮询确认。
    final temperature = switch (mode) {
      AirconMode.heat => 23,
      AirconMode.cool => 26,
      _ => 25,
    };
    final windSpeed = mode == AirconMode.fan
        ? AirconWindSpeed.medium
        : AirconWindSpeed.auto;
    _sendCommand(
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

  void _setWindSpeed(AirconState state, AirconWindSpeed speed) {
    if (speed == state.windSpeed && !state.strongMode) return;
    _sendCommand(
      command: {"windSpeed": speed.value.toString(), "strongMode": 0},
      optimisticState: state.copyWith(windSpeed: speed, strongMode: false),
      matches: (state) => state.windSpeed == speed && !state.strongMode,
    );
  }

  void _setVerticalSwing(AirconState state, bool value) => _sendCommand(
    command: {"verticalSwing": value ? 1 : 0},
    optimisticState: state.copyWith(verticalSwing: value),
    matches: (state) => state.verticalSwing == value,
  );

  void _setStrongMode(AirconState state, bool value) => _sendCommand(
    command: {
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

  void _setElectricHeating(AirconState state, bool value) => _sendCommand(
    command: {"electricHeating": value ? 1 : 0},
    optimisticState: state.copyWith(electricHeating: value),
    matches: (state) => state.electricHeating == value,
  );

  // --- 外观 ---

  /// 顶部渐变用主题色区分运行模式，关机时改用表面色。
  List<Color> _gradientColors(BuildContext context, AirconState? state) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerLow;
    if (state == null || !state.isOn) {
      return [scheme.surfaceContainerHighest, base];
    }
    final accent = switch (state.mode) {
      AirconMode.heat => scheme.tertiary,
      AirconMode.cool => scheme.primary,
      AirconMode.dry => scheme.secondary,
      AirconMode.fan => scheme.onSurfaceVariant,
      AirconMode.auto => scheme.primaryContainer,
    };
    return [Color.lerp(base, accent, 0.24)!, base];
  }

  IconData _modeIcon(AirconMode mode) => switch (mode) {
    AirconMode.cool => Icons.ac_unit,
    AirconMode.heat => Icons.wb_sunny_outlined,
    AirconMode.dry => Icons.water_drop_outlined,
    AirconMode.fan => Icons.air,
    AirconMode.auto => Icons.auto_mode,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      body: SignalBuilder(
        builder: (context) {
          if (_controller.imeiSignal.value.isEmpty) {
            return _message(
              context,
              context.t.electricity.airconImeiMissing,
              onPressed: _configure,
              actionLabel: context.t.electricity.airconAddImei,
              actionIcon: Icons.settings_outlined,
            );
          }

          final state = _state;
          if (state == null) {
            if (_error != null) {
              return _message(
                context,
                context.t.electricity.airconControlError,
                details: _error.toString(),
                onPressed: _refreshDeviceState,
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final busy = _isFetching || _pendingMatches != null;
          final gradient = _gradientColors(context, state);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 80,
                    expandedHeight: 240,
                    backgroundColor: scheme.surfaceContainerLow,
                    surfaceTintColor: scheme.surfaceContainerLow,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    leading: Center(
                      child: _PressScaleFeedback(
                        child: IconButton(
                          onPressed: _isFetching ? null : _refreshDeviceState,
                          tooltip: context.t.electricity.update,
                          color: scheme.onSurfaceVariant,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                    actions: [
                      _PressScaleFeedback(
                        child: IconButton(
                          onPressed: busy ? null : _configure,
                          tooltip: context.t.setting.airconImeiTitle,
                          color: scheme.onSurfaceVariant,
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final top = MediaQuery.paddingOf(context).top;
                        final expansion =
                            ((constraints.maxHeight - top - 80) / 160).clamp(
                              0.0,
                              1.0,
                            );
                        // 温度和模式随顶部可用高度一起缩小。
                        return AnimatedContainer(
                          duration: _stateMotionDuration,
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: gradient,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(56, top, 56, 0),
                            child: Center(
                              child: _hero(context, state, expansion),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      32 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverList.list(
                      children: [
                        if (_error != null)
                          _CardEntrance(
                            index: 1,
                            child: _errorCard(context, _error!),
                          ),
                        _CardEntrance(index: 2, child: _energyCard(context)),
                        _CardEntrance(
                          index: 3,
                          child: _powerCard(context, state, busy),
                        ),
                        _CardEntrance(
                          index: 4,
                          child: _temperatureCard(context, state, busy),
                        ),
                        _CardEntrance(
                          index: 5,
                          child: _windCard(context, state, busy),
                        ),
                        _CardEntrance(
                          index: 6,
                          child: _swingCard(context, state, busy),
                        ),
                        _CardEntrance(
                          index: 7,
                          child: _otherCard(context, state, busy),
                        ),
                        _CardEntrance(
                          index: 8,
                          child: _modeCard(context, state, busy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (busy)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _hero(BuildContext context, AirconState state, double expansion) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!state.isOn)
            Text(
              context.t.electricity.airconPower,
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.targetTemperature.toString(),
                  style: textTheme.displayLarge?.copyWith(
                    color: scheme.onSurface,
                    fontSize: 28 + 64 * expansion,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3 + 7 * expansion, left: 2),
                  child: Text(
                    "℃",
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontSize: 14 + 8 * expansion,
                      height: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _modeIcon(state.mode),
                size: 16 + 4 * expansion,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                context.t.resolveKey(state.mode.labelKey),
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 12 + 4 * expansion,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context, Object error) {
    final scheme = Theme.of(context).colorScheme;
    return _MiCard(
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.toString(),
              style: TextStyle(color: scheme.error, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: _isFetching ? null : _refreshDeviceState,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  /// 用电信息：平台用电量、室内温度、更新时间。
  Widget _energyCard(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final async = _controller.energyInfoStateSignal.value;
        final info = async.value?.data;
        final state = _state;

        String amount = "--";
        String update = "--";
        if (info != null) {
          amount = info.electricAmount.toString();
          final time = info.stateTime;
          update =
              "${time.hour.toString().padLeft(2, "0")}:"
              "${time.minute.toString().padLeft(2, "0")}";
        }
        final indoor = state?.indoorTemperature;

        return _MiCard(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          onTap: _isFetching ? null : _controller.refreshEnergyInfo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t.electricity.airconTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _energyValue(
                    context,
                    amount,
                    context.t.electricity.airconAmount,
                  ),
                  _energyValue(
                    context,
                    indoor == null ? "--" : indoor.toString(),
                    context.t.electricity.airconIndoor,
                  ),
                  _energyValue(
                    context,
                    update,
                    context.t.electricity.airconUpdateTime,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _energyValue(BuildContext context, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// 电源：一个圆钮，按下去会缩一下。
  Widget _powerCard(BuildContext context, AirconState state, bool busy) {
    return _MiCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.power_settings_new,
            size: 64,
            selected: state.isOn,
            accent: state.isOn
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.primary,
            onAccent: state.isOn
                ? Theme.of(context).colorScheme.onTertiary
                : Theme.of(context).colorScheme.onPrimary,
            enabled: !busy,
            onTap: () => _setPower(state, !state.isOn),
          ),
          const SizedBox(width: 14),
          Text(
            context.t.electricity.airconPower,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// 温度调节：减号、滑条、加号。
  Widget _temperatureCard(BuildContext context, AirconState state, bool busy) {
    final scheme = Theme.of(context).colorScheme;
    final fraction =
        (state.targetTemperature - _minTemperature) /
        (_maxTemperature - _minTemperature);

    return _MiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.t.electricity.airconTargetTemperature,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 1,
                height: 16,
                child: ColoredBox(color: scheme.outlineVariant),
              ),
              const SizedBox(width: 10),
              Text(
                "$_minTemperature-$_maxTemperature℃",
                style: TextStyle(fontSize: 13, color: scheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RoundButton(
                icon: Icons.remove,
                selected: false,
                accent: Theme.of(context).colorScheme.primary,
                enabled: !busy && state.targetTemperature > _minTemperature,
                onTap: () =>
                    _setTemperature(state, state.targetTemperature - 1),
              ),
              const SizedBox(width: 12),

              // 温度条显示当前设定值，填充比例随温度变化。
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: fraction.clamp(0.0, 1.0)),
                  duration: _stateMotionDuration,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: value,
                          child: AnimatedContainer(
                            duration: _stateMotionDuration,
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: state.isOn
                                  ? Theme.of(context).colorScheme.primary
                                  : scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                        ),
                        Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: _DirectionalTemperature(
                                value: state.targetTemperature,
                                suffix: "℃",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _RoundButton(
                icon: Icons.add,
                selected: false,
                accent: Theme.of(context).colorScheme.primary,
                enabled: !busy && state.targetTemperature < _maxTemperature,
                onTap: () =>
                    _setTemperature(state, state.targetTemperature + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 风速使用一排圆钮选择。
  Widget _windCard(BuildContext context, AirconState state, bool busy) {
    final scheme = Theme.of(context).colorScheme;
    return _MiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.t.electricity.airconWindSpeed,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 1,
                height: 16,
                child: ColoredBox(color: scheme.outlineVariant),
              ),
              const SizedBox(width: 10),
              Text(
                context.t.resolveKey(state.windSpeed.labelKey),
                style: TextStyle(fontSize: 13, color: scheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SlidingOptionRow(
            items: [
              for (final speed in AirconWindSpeed.values)
                _SlidingOptionItem(
                  letter: _windLetter(speed),
                  label: context.t.resolveKey(speed.labelKey),
                  selected: state.windSpeed == speed && !state.strongMode,
                  onTap: () => _setWindSpeed(state, speed),
                ),
            ],
            selectedIndex: state.strongMode
                ? -1
                : AirconWindSpeed.values.indexOf(state.windSpeed),
            enabled: !busy,
          ),
        ],
      ),
    );
  }

  String _windLetter(AirconWindSpeed speed) => switch (speed) {
    AirconWindSpeed.auto => "A",
    AirconWindSpeed.silent => "S",
    AirconWindSpeed.low => "L",
    AirconWindSpeed.medium => "M",
    AirconWindSpeed.high => "H",
  };

  /// 设备仅支持上下扫风，使用圆钮和开关控制。
  Widget _swingCard(BuildContext context, AirconState state, bool busy) {
    return _MiCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.swap_vert,
            selected: state.verticalSwing,
            accent: Theme.of(context).colorScheme.primary,
            enabled: !busy,
            size: 52,
            onTap: () => _setVerticalSwing(state, !state.verticalSwing),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              context.t.electricity.airconVerticalSwing,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: state.verticalSwing,
            onChanged: busy ? null : (value) => _setVerticalSwing(state, value),
          ),
        ],
      ),
    );
  }

  /// 强力模式和辅助电热共用一张卡片。
  Widget _otherCard(BuildContext context, AirconState state, bool busy) {
    Widget row({
      required IconData icon,
      required String label,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return _SwitchRow(
        icon: icon,
        label: label,
        value: value,
        enabled: !busy,
        onChanged: onChanged,
      );
    }

    return _MiCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Column(
        children: [
          row(
            icon: Icons.bolt_outlined,
            label: context.t.electricity.airconStrongMode,
            value: state.strongMode,
            onChanged: (value) => _setStrongMode(state, value),
          ),
          const Divider(height: 1),
          row(
            icon: Icons.local_fire_department_outlined,
            label: context.t.electricity.airconElectricHeating,
            value: state.electricHeating,
            onChanged: (value) => _setElectricHeating(state, value),
          ),
        ],
      ),
    );
  }

  /// 运行模式：一排圆钮。
  Widget _modeCard(BuildContext context, AirconState state, bool busy) {
    /// 顺序照米家：制冷、制热、自动、送风、除湿。
    const order = [
      AirconMode.cool,
      AirconMode.heat,
      AirconMode.auto,
      AirconMode.fan,
      AirconMode.dry,
    ];

    return _MiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t.electricity.airconMode,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          _SlidingOptionRow(
            items: [
              for (final mode in order)
                _SlidingOptionItem(
                  icon: _modeIcon(mode),
                  label: context.t.resolveKey(mode.labelKey),
                  selected: state.mode == mode,
                  onTap: () => _setMode(state, mode),
                ),
            ],
            selectedIndex: order.indexOf(state.mode),
            enabled: !busy,
          ),
        ],
      ),
    );
  }

  Widget _message(
    BuildContext context,
    String message, {
    String? details,
    required VoidCallback onPressed,
    String? actionLabel,
    IconData actionIcon = Icons.refresh,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ac_unit, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(actionIcon),
              label: Text(actionLabel ?? context.t.electricity.airconRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressScaleFeedback extends StatefulWidget {
  const _PressScaleFeedback({required this.child});

  final Widget child;

  @override
  State<_PressScaleFeedback> createState() => _PressScaleFeedbackState();
}

class _PressScaleFeedbackState extends State<_PressScaleFeedback> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: _pressMotionDuration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _CardEntrance extends StatefulWidget {
  const _CardEntrance({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_CardEntrance> createState() => _CardEntranceState();
}

class _CardEntranceState extends State<_CardEntrance> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final delay = widget.index * 40;
    final total = delay + 260;
    // 先提交一个可见首帧，再开始错峰入场。
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _started ? 1 : 0),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      child: widget.child,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: child,
      ),
    );
  }
}

class _DirectionalTemperature extends StatefulWidget {
  const _DirectionalTemperature({
    required this.value,
    required this.style,
    this.suffix = "",
  });
  final int value;
  final TextStyle? style;
  final String suffix;
  @override
  State<_DirectionalTemperature> createState() =>
      _DirectionalTemperatureState();
}

class _DirectionalTemperatureState extends State<_DirectionalTemperature> {
  late int _oldValue = widget.value;
  @override
  void didUpdateWidget(covariant _DirectionalTemperature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _oldValue = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    final increasing = widget.value > _oldValue;
    return AnimatedSwitcher(
      duration: _stateMotionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final childValue = (child.key as ValueKey<int>).value;
        final incoming = childValue == widget.value;
        final offset = increasing
            ? (incoming ? const Offset(0, 1) : const Offset(0, -1))
            : (incoming ? const Offset(0, -1) : const Offset(0, 1));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: offset, end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        "${widget.value}${widget.suffix}",
        key: ValueKey(widget.value),
        style: widget.style,
      ),
    );
  }
}

class _SlidingOptionItem {
  const _SlidingOptionItem({
    this.icon,
    this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData? icon;
  final String? letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _SlidingOptionRow extends StatelessWidget {
  const _SlidingOptionRow({
    required this.items,
    required this.selectedIndex,
    required this.enabled,
  });
  final List<_SlidingOptionItem> items;
  final int selectedIndex;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = constraints.maxWidth / items.length;
          return Stack(
            children: [
              if (selectedIndex >= 0)
                AnimatedPositioned(
                  duration: _stateMotionDuration,
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * slot + (slot - 54) / 2,
                  top: 0,
                  width: 54,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              for (var i = 0; i < items.length; i++)
                Positioned(
                  left: i * slot,
                  width: slot,
                  top: 0,
                  child: _SlidingOptionCell(
                    item: items[i],
                    selected: i == selectedIndex,
                    enabled: enabled,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SlidingOptionCell extends StatefulWidget {
  const _SlidingOptionCell({
    required this.item,
    required this.selected,
    required this.enabled,
  });
  final _SlidingOptionItem item;
  final bool selected;
  final bool enabled;
  @override
  State<_SlidingOptionCell> createState() => _SlidingOptionCellState();
}

class _SlidingOptionCellState extends State<_SlidingOptionCell> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.selected
        ? scheme.onPrimary
        : (widget.enabled ? scheme.onSurfaceVariant : scheme.outline);
    return GestureDetector(
      onTap: widget.enabled ? widget.item.onTap : null,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: _pressMotionDuration,
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: _stateMotionDuration,
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                  child: widget.item.letter != null
                      ? Text(widget.item.letter!)
                      : TweenAnimationBuilder<Color?>(
                          tween: ColorTween(end: color),
                          duration: _stateMotionDuration,
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedColor, _) => Icon(
                            widget.item.icon,
                            size: 24,
                            color: animatedColor,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: _stateMotionDuration,
              style: TextStyle(
                fontSize: 12,
                color: widget.selected
                    ? Theme.of(context).colorScheme.primary
                    : scheme.onSurfaceVariant,
                fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 米家风格的圆角卡片，带轻微阴影。
class _MiCard extends StatelessWidget {
  const _MiCard({required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: onTap == null
            ? content
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  child: content,
                ),
              ),
      ),
    );
  }
}

/// 圆形按钮用主题强调色表示选中状态。
class _RoundButton extends StatefulWidget {
  const _RoundButton({
    this.icon,
    required this.selected,
    required this.accent,
    this.onAccent,
    required this.onTap,
    this.enabled = true,
    this.size = 56,
  });

  final IconData? icon;

  final bool selected;
  final Color accent;
  final Color? onAccent;
  final VoidCallback onTap;
  final bool enabled;
  final double size;

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = !widget.enabled
        ? scheme.surfaceContainerHighest
        : widget.selected
        ? widget.accent
        : scheme.surfaceContainerHighest;
    final foreground = !widget.enabled
        ? scheme.outline
        : widget.selected
        ? (widget.onAccent ?? scheme.onPrimary)
        : scheme.onSurfaceVariant;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: _pressMotionDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: _stateMotionDuration,
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(
            widget.icon ?? Icons.circle,
            size: widget.size * 0.5,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// 一行开关，左边一个圆图标、中间文字、右边开关。
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: _stateMotionDuration,
            curve: Curves.easeOutCubic,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: value
                  ? Theme.of(context).colorScheme.primary
                  : scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: value ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}
