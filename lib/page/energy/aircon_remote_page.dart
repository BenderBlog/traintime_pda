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

class AirconRemotePage extends StatefulWidget {
  const AirconRemotePage({super.key});

  @override
  State<AirconRemotePage> createState() => _AirconRemotePageState();
}

class _AirconRemotePageState extends State<AirconRemotePage> {
  final _controller = AirconController.i;

  @override
  void initState() {
    super.initState();
    Future.microtask(_controller.refreshDeviceState);
  }

  Future<void> _configure() async {
    await showDialog<void>(
      context: context,
      builder: (context) => const AirconImeiDialog(),
    );
    await _controller.refreshDeviceState();
  }

  Future<void> _send(Future<void> command) async {
    try {
      await command;
      if (!mounted) return;
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "electricity.aircon_command_ok"),
      );
    } catch (error) {
      if (!mounted) return;
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
            onPressed: _controller.refreshDeviceState,
            tooltip: FlutterI18n.translate(context, "electricity.update"),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _configure,
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

          final busyControls = _controller.controllingControlsSignal.value;
          return _controller.deviceStateSignal.value.map(
            data: (state) => Stack(
              children: [
                _controls(context, state, busyControls),
                if (busyControls.isNotEmpty) const LinearProgressIndicator(),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            refreshing: () => const Center(child: CircularProgressIndicator()),
            reloading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _message(
              context,
              "electricity.aircon_control_error",
              details: error.toString(),
              onPressed: _controller.refreshDeviceState,
            ),
          );
        },
      ),
    );
  }

  Widget _controls(
    BuildContext context,
    AirconState state,
    Set<AirconControl> busyControls,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.power_settings_new),
                title: Text(
                  FlutterI18n.translate(context, "electricity.aircon_power"),
                ),
                value: state.isOn,
                onChanged: busyControls.contains(AirconControl.power)
                    ? null
                    : (value) => _send(_controller.setPower(value)),
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
                      onPressed:
                          busyControls.contains(AirconControl.temperature) ||
                              state.targetTemperature <= 18
                          ? null
                          : () => _send(
                              _controller.setTemperature(
                                state.targetTemperature - 1,
                              ),
                            ),
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 68,
                      child: TextFormField(
                        key: ValueKey(state.targetTemperature),
                        initialValue: state.targetTemperature.toString(),
                        enabled: !busyControls.contains(
                          AirconControl.temperature,
                        ),
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
                            _send(_controller.setTemperature(temperature));
                          }
                        },
                      ),
                    ),
                    IconButton(
                      onPressed:
                          busyControls.contains(AirconControl.temperature) ||
                              state.targetTemperature >= 32
                          ? null
                          : () => _send(
                              _controller.setTemperature(
                                state.targetTemperature + 1,
                              ),
                            ),
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
          enabled: !busyControls.contains(AirconControl.mode),
          labelKey: (mode) => mode.labelKey,
          onSelected: (mode) => _send(_controller.setMode(mode)),
        ),
        _choiceSection<AirconWindSpeed>(
          context,
          titleKey: "electricity.aircon_wind_speed",
          values: AirconWindSpeed.values,
          selected: state.windSpeed,
          enabled: !busyControls.contains(AirconControl.windSpeed),
          labelKey: (speed) => speed.labelKey,
          onSelected: (speed) => _send(_controller.setWindSpeed(speed)),
        ),
        Card(
          child: Column(
            children: [
              _featureSwitch(
                context,
                icon: Icons.swap_vert,
                labelKey: "electricity.aircon_vertical_swing",
                value: state.verticalSwing,
                enabled: !busyControls.contains(AirconControl.verticalSwing),
                onChanged: (value) =>
                    _send(_controller.setVerticalSwing(value)),
              ),
              _featureSwitch(
                context,
                icon: Icons.air,
                labelKey: "electricity.aircon_strong_mode",
                value: state.strongMode,
                enabled: !busyControls.contains(AirconControl.strongMode),
                onChanged: (value) => _send(_controller.setStrongMode(value)),
              ),
              _featureSwitch(
                context,
                icon: Icons.local_fire_department,
                labelKey: "electricity.aircon_electric_heating",
                value: state.electricHeating,
                enabled: !busyControls.contains(AirconControl.electricHeating),
                onChanged: (value) =>
                    _send(_controller.setElectricHeating(value)),
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
