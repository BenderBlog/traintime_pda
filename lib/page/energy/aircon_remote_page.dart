// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/aircon_imei_dialog.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';

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

  static const _pollInterval = Duration(milliseconds: 300);
  static const _pollAttempts = 12;

  @override
  void initState() {
    super.initState();
    _state = _controller.deviceStateSignal.peek().value;
    Future.microtask(_refreshDeviceState);
  }

  Future<void> _configure() async {
    await showDialog<void>(
      context: context,
      builder: (context) => const AirconImeiDialog(),
    );
    if (!mounted) return;
    setState(() {
      _state = null;
      _error = null;
    });
    await _refreshDeviceState();
  }

  Future<void> _refreshDeviceState() async {
    final imei = _controller.imeiSignal.value;
    if (imei.isEmpty || _isFetching) return;

    setState(() {
      _isFetching = true;
      _error = null;
    });

    try {
      final state = await _controller.session.getDeviceState(imei);
      if (!mounted || imei != _controller.imeiSignal.value) return;

      final matches = _pendingMatches;
      if (matches != null && !matches(state)) {
        setState(() {
          _error = const AirconResponseException("设备状态仍未确认");
          _isFetching = false;
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
      setState(() {
        _error = error;
        _isFetching = false;
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
        if (!mounted || imei != _controller.imeiSignal.value) return;

        try {
          final state = await _controller.session.getDeviceState(imei);
          if (matches(state)) {
            confirmedState = state;
            break;
          }
        } catch (error) {
          pollError = error;
        }
      }

      if (!mounted || imei != _controller.imeiSignal.value) return;
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
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "electricity.aircon_command_ok"),
      );
    } catch (error) {
      if (!mounted || imei != _controller.imeiSignal.value) return;
      setState(() {
        _error = error;
        _isFetching = false;
        if (!commandSent) {
          _state = previous;
          _pendingMatches = null;
        }
      });
      showToast(context: context, msg: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "electricity.aircon_remote"),
        ),
        actions: [
          IconButton(
            onPressed: _isFetching ? null : _refreshDeviceState,
            tooltip: FlutterI18n.translate(context, "electricity.update"),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _isFetching || _pendingMatches != null
                ? null
                : _configure,
            tooltip: FlutterI18n.translate(
              context,
              "setting.aircon_imei_title",
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SignalBuilder(
        builder: (context) {
          if (_controller.imeiSignal.value.isEmpty) {
            return _message(
              context,
              "electricity.aircon_imei_missing",
              onPressed: _configure,
              actionKey: "electricity.aircon_add_imei",
              actionIcon: Icons.settings,
            );
          }

          final state = _state;
          if (state == null) {
            if (_error != null) {
              return _message(
                context,
                "electricity.aircon_control_error",
                details: _error.toString(),
                onPressed: _refreshDeviceState,
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final busy = _isFetching || _pendingMatches != null;
          return Stack(
            children: [
              _controls(context, state, busy, _error),
              if (busy) const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }

  Widget _controls(
    BuildContext context,
    AirconState state,
    bool busy,
    Object? error,
  ) {
    void setTemperature(int value) => _sendCommand(
      command: {"tempSet": value},
      optimisticState: state.copyWith(targetTemperature: value),
      matches: (state) => state.targetTemperature == value,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (error != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(error.toString()),
              trailing: IconButton(
                onPressed: _isFetching ? null : _refreshDeviceState,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.power_settings_new),
                title: Text(
                  FlutterI18n.translate(context, "electricity.aircon_power"),
                ),
                value: state.isOn,
                onChanged: busy
                    ? null
                    : (value) => _sendCommand(
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
                          electricHeating: value
                              ? state.electricHeating
                              : false,
                        ),
                        matches: (state) => state.isOn == value,
                      ),
              ),
              ListTile(
                leading: const Icon(Icons.device_thermostat),
                title: Text(
                  FlutterI18n.translate(
                    context,
                    "electricity.aircon_target_temperature",
                  ),
                ),
                subtitle: state.indoorTemperature == null
                    ? null
                    : Text(
                        FlutterI18n.translate(
                          context,
                          "electricity.aircon_indoor_temperature",
                          translationParams: {
                            "temperature": state.indoorTemperature.toString(),
                          },
                        ),
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: busy || state.targetTemperature <= 18
                          ? null
                          : () => setTemperature(state.targetTemperature - 1),
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 68,
                      child: TextFormField(
                        key: ValueKey(state.targetTemperature),
                        initialValue: state.targetTemperature.toString(),
                        enabled: !busy,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          suffixText: "℃",
                        ),
                        onFieldSubmitted: (value) {
                          final temperature = int.tryParse(value);
                          if (temperature == null ||
                              temperature < 18 ||
                              temperature > 32) {
                            showToast(
                              context: context,
                              msg: FlutterI18n.translate(
                                context,
                                "electricity.aircon_temperature_range",
                              ),
                            );
                            return;
                          }
                          if (temperature != state.targetTemperature) {
                            setTemperature(temperature);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: busy || state.targetTemperature >= 32
                          ? null
                          : () => setTemperature(state.targetTemperature + 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _choiceSection<AirconMode>(
          context,
          titleKey: "electricity.aircon_mode",
          values: AirconMode.values,
          selected: state.mode,
          enabled: !busy,
          labelKey: (mode) => mode.labelKey,
          onSelected: (mode) {
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
          },
        ),
        _choiceSection<AirconWindSpeed>(
          context,
          titleKey: "electricity.aircon_wind_speed",
          values: AirconWindSpeed.values,
          selected: state.windSpeed,
          enabled: !busy,
          labelKey: (speed) => speed.labelKey,
          onSelected: (speed) => _sendCommand(
            command: {"windSpeed": speed.value.toString(), "strongMode": 0},
            optimisticState: state.copyWith(
              windSpeed: speed,
              strongMode: false,
            ),
            matches: (state) => state.windSpeed == speed && !state.strongMode,
          ),
        ),
        Card(
          child: Column(
            children: [
              _featureSwitch(
                context,
                icon: Icons.swap_vert,
                labelKey: "electricity.aircon_vertical_swing",
                value: state.verticalSwing,
                enabled: !busy,
                onChanged: (value) => _sendCommand(
                  command: {"verticalSwing": value ? 1 : 0},
                  optimisticState: state.copyWith(verticalSwing: value),
                  matches: (state) => state.verticalSwing == value,
                ),
              ),
              _featureSwitch(
                context,
                icon: Icons.air,
                labelKey: "electricity.aircon_strong_mode",
                value: state.strongMode,
                enabled: !busy,
                onChanged: (value) => _sendCommand(
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
                ),
              ),
              _featureSwitch(
                context,
                icon: Icons.local_fire_department,
                labelKey: "electricity.aircon_electric_heating",
                value: state.electricHeating,
                enabled: !busy,
                onChanged: (value) => _sendCommand(
                  command: {"electricHeating": value ? 1 : 0},
                  optimisticState: state.copyWith(electricHeating: value),
                  matches: (state) => state.electricHeating == value,
                ),
              ),
            ],
          ),
        ),
        if (state.electricAmount != null)
          ListTile(
            leading: const Icon(Icons.electric_bolt),
            title: Text(
              FlutterI18n.translate(context, "electricity.aircon_amount"),
            ),
            trailing: Text(state.electricAmount.toString()),
          ),
      ],
    );
  }

  Widget _featureSwitch(
    BuildContext context, {
    required IconData icon,
    required String labelKey,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(FlutterI18n.translate(context, labelKey)),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _choiceSection<T>(
    BuildContext context, {
    required String titleKey,
    required List<T> values,
    required T selected,
    required bool enabled,
    required String Function(T value) labelKey,
    required ValueChanged<T> onSelected,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FlutterI18n.translate(context, titleKey),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: values
                  .map(
                    (value) => ChoiceChip(
                      label: Text(
                        FlutterI18n.translate(context, labelKey(value)),
                      ),
                      selected: value == selected,
                      onSelected: enabled ? (_) => onSelected(value) : null,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(
    BuildContext context,
    String key, {
    String? details,
    required VoidCallback onPressed,
    String actionKey = "electricity.aircon_retry",
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
            Text(
              FlutterI18n.translate(context, key),
              textAlign: TextAlign.center,
            ),
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
              label: Text(FlutterI18n.translate(context, actionKey)),
            ),
          ],
        ),
      ),
    );
  }
}
