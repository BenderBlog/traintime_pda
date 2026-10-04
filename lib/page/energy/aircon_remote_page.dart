// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/page/public_widget/setting/setting_header.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/aircon_imei_page.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';

class AirconRemotePage extends StatefulWidget {
  const AirconRemotePage({super.key});

  @override
  State<AirconRemotePage> createState() => _AirconRemotePageState();
}

class _AirconRemotePageState extends State<AirconRemotePage> {
  final _controller = AirconController.i;
  final _temperatureFocusNode = FocusNode();
  AirconState? _state;
  Object? _error;
  bool _isFetching = false;
  bool Function(AirconState state)? _pendingMatches;

  static const _pollInterval = Duration(milliseconds: 300);
  static const _pollAttempts = 12;

  @override
  void dispose() {
    _temperatureFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _state = _controller.deviceStateSignal.peek().value;
    Future.microtask(_refreshDeviceState);
  }

  Future<void> _configure() async {
    await context.push<void>(const AirconImeiPage());
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
      showToast(context: context, msg: context.t.electricity.airconCommandOk);
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
        title: Text(context.t.electricity.airconRemote),
        actions: [
          IconButton(
            onPressed: _isFetching ? null : _refreshDeviceState,
            tooltip: context.t.electricity.update,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _isFetching || _pendingMatches != null
                ? null
                : _configure,
            tooltip: context.t.setting.airconImeiTitle,
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
        SettingHeader(
          title: context.t.electricity.airconControlSection,
          icon: Icons.power_settings_new,
        ),
        _AirconSegmentedSwitchGroup(
          items: [
            _AirconSwitchItem(
              icon: Icons.power_settings_new,
              title: context.t.electricity.airconPower,
              value: state.isOn,
              onChanged: (value) => _sendCommand(
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
              ),
            ),
          ],
          enabled: !busy,
        ),
        const SizedBox(height: 8),
        M3ESegmentedList(
          itemCount: 1,
          outerRadius: 28,
          padding: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          isEnabled: (index) => !busy,
          onTap: (index) => _temperatureFocusNode.requestFocus(),
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.device_thermostat),
            title: Text(context.t.electricity.airconTargetTemperature),
            subtitle: state.indoorTemperature != null
                ? Text(
                    context.t.electricity.airconIndoorTemperature(
                      temperature: state.indoorTemperature.toString(),
                    ),
                  )
                : null,
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
                  width: 80,
                  child: TextFormField(
                    key: ValueKey(state.targetTemperature),
                    focusNode: _temperatureFocusNode,
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
                          msg: context.t.electricity.airconTemperatureRange,
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
        ),
        SettingHeader(
          title: context.t.electricity.airconOperationSection,
          icon: Icons.settings_remote,
        ),
        M3ESegmentedList(
          itemCount: 2,
          outerRadius: 28,
          innerRadius: 6,
          gap: 3,
          padding: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 10),
            child: switch (index) {
              0 => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.ac_unit),
                    title: Text(context.t.electricity.airconMode),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final buttonWidth =
                          constraints.maxWidth / AirconMode.values.length;
                      return M3EToggleButtonGroup(
                        type: M3EButtonGroupType.standard,
                        size: M3EButtonSize.xs,
                        spacing: 0,
                        actions: AirconMode.values
                            .map(
                              (mode) => M3EToggleButtonGroupAction(
                                label: Text(
                                  context.t.resolveKey(mode.labelKey),
                                ),
                                enabled: !busy,
                                width: buttonWidth,
                              ),
                            )
                            .toList(),
                        selectedIndex: AirconMode.values.indexOf(state.mode),
                        onSelectedIndexChanged: (index) {
                          if (index == null || busy) return;
                          final mode = AirconMode.values[index];
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
                        overflow: M3EButtonGroupOverflow.none,
                        neighborSquish: true,
                      );
                    },
                  ),
                ],
              ),
              _ => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.air),
                    title: Text(context.t.electricity.airconWindSpeed),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final buttonWidth =
                          constraints.maxWidth / AirconWindSpeed.values.length;
                      return M3EToggleButtonGroup(
                        type: M3EButtonGroupType.standard,
                        size: M3EButtonSize.xs,
                        spacing: 0,
                        actions: AirconWindSpeed.values
                            .map(
                              (speed) => M3EToggleButtonGroupAction(
                                label: Text(
                                  context.t.resolveKey(speed.labelKey),
                                ),
                                enabled: !busy,
                                width: buttonWidth,
                              ),
                            )
                            .toList(),
                        selectedIndex: AirconWindSpeed.values.indexOf(
                          state.windSpeed,
                        ),
                        onSelectedIndexChanged: (index) {
                          if (index == null || busy) return;
                          final speed = AirconWindSpeed.values[index];
                          _sendCommand(
                            command: {
                              "windSpeed": speed.value.toString(),
                              "strongMode": 0,
                            },
                            optimisticState: state.copyWith(
                              windSpeed: speed,
                              strongMode: false,
                            ),
                            matches: (state) =>
                                state.windSpeed == speed && !state.strongMode,
                          );
                        },
                        overflow: M3EButtonGroupOverflow.none,
                        neighborSquish: true,
                      );
                    },
                  ),
                ],
              ),
            },
          ),
        ),
        SettingHeader(
          title: context.t.electricity.airconOtherSettingsSection,
          icon: Icons.tune,
        ),
        _AirconSegmentedSwitchGroup(
          enabled: !busy,
          items: [
            _AirconSwitchItem(
              icon: Icons.swap_vert,
              title: context.t.electricity.airconVerticalSwing,
              value: state.verticalSwing,
              onChanged: (value) => _sendCommand(
                command: {"verticalSwing": value ? 1 : 0},
                optimisticState: state.copyWith(verticalSwing: value),
                matches: (state) => state.verticalSwing == value,
              ),
            ),
            _AirconSwitchItem(
              icon: Icons.air,
              title: context.t.electricity.airconStrongMode,
              value: state.strongMode,
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
            _AirconSwitchItem(
              icon: Icons.local_fire_department,
              title: context.t.electricity.airconElectricHeating,
              value: state.electricHeating,
              onChanged: (value) => _sendCommand(
                command: {"electricHeating": value ? 1 : 0},
                optimisticState: state.copyWith(electricHeating: value),
                matches: (state) => state.electricHeating == value,
              ),
            ),
          ],
        ),
        // if (state.electricAmount != null)
        //   ListTile(
        //     leading: const Icon(Icons.electric_bolt),
        //     title: Text(
        //       context.t.electricity.airconAmount,
        //     ),
        //     trailing: Text(state.electricAmount.toString()),
        //   ),
      ],
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
            Text(context.t.resolveKey(key), textAlign: TextAlign.center),
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
              label: Text(context.t.resolveKey(actionKey)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AirconSwitchItem {
  const _AirconSwitchItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class _AirconSegmentedSwitchGroup extends StatelessWidget {
  const _AirconSegmentedSwitchGroup({
    required this.items,
    required this.enabled,
  });

  final List<_AirconSwitchItem> items;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return M3ESegmentedColumn(
      outerRadius: 28,
      innerRadius: 6,
      gap: 3,
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      selectionMode: M3ESelectionMode.multiple,
      selectionTrigger: M3ESelectionTrigger.none,
      isSelected: (index) => items[index].value,
      selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
      selectedRadius: 20,
      pressedRadius: 4,
      pressedScale: 0.98,
      splashFactory: InkSparkle.splashFactory,
      isEnabled: (index) => enabled,
      onTap: (index) => items[index].onChanged(!items[index].value),
      children: [
        for (final item in items)
          Row(
            children: [
              Icon(item.icon, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 8),
              IgnorePointer(
                child: Switch(
                  value: item.value,
                  onChanged: enabled ? item.onChanged : null,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
