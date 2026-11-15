// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/page/aircon/aircon_remote_widgets.dart';
import 'package:watermeter/repository/translation_key.dart';

/// 构建遥控页各部分，并通过回调将操作交回页面处理。
class AirconRemoteCards {
  const AirconRemoteCards({
    required AirconController controller,
    required AirconState? state,
    required bool isFetching,
    required VoidCallback onRefresh,
    required void Function(AirconRemoteCommand?) onCommand,
  }) : _controller = controller,
       _state = state,
       _isFetching = isFetching,
       _refreshDeviceState = onRefresh,
       _sendCommand = onCommand;

  final AirconController _controller;
  final AirconState? _state;
  final bool _isFetching;
  final VoidCallback _refreshDeviceState;
  final void Function(AirconRemoteCommand?) _sendCommand;

  List<Color> gradientColors(BuildContext context, AirconState? state) {
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

  Widget hero(BuildContext context, AirconState state, double expansion) {
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

  Widget errorCard(BuildContext context, Object error) {
    final scheme = Theme.of(context).colorScheme;
    return AirconMiCard(
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

  Widget energyCard(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final async = _controller.energyInfoStateSignal.value;
        final result = async.value;
        final info = result?.data;
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

        return AirconMiCard(
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
              if (result != null && result.isCache) ...[
                const SizedBox(height: 12),
                Text(
                  context.t.electricity.airconCacheNotice(
                    time: DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(result.fetchTime),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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

  Widget powerCard(BuildContext context, AirconState state, bool busy) {
    return AirconMiCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          AirconRoundButton(
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
            onTap: () =>
                _sendCommand(_controller.powerCommand(state, !state.isOn)),
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

  Widget temperatureCard(BuildContext context, AirconState state, bool busy) {
    final scheme = Theme.of(context).colorScheme;
    final fraction =
        (state.targetTemperature - minTemperature) /
        (maxTemperature - minTemperature);

    return AirconMiCard(
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
                "$minTemperature-$maxTemperature℃",
                style: TextStyle(fontSize: 13, color: scheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AirconRoundButton(
                icon: Icons.remove,
                selected: false,
                accent: Theme.of(context).colorScheme.primary,
                enabled: !busy && state.targetTemperature > minTemperature,
                onTap: () => _sendCommand(
                  _controller.temperatureCommand(
                    state,
                    state.targetTemperature - 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 温度条显示当前设定值，填充比例随温度变化。
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: fraction.clamp(0.0, 1.0)),
                  duration: stateMotionDuration,
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
                            duration: stateMotionDuration,
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
                              child: AirconDirectionalTemperature(
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
              AirconRoundButton(
                icon: Icons.add,
                selected: false,
                accent: Theme.of(context).colorScheme.primary,
                enabled: !busy && state.targetTemperature < maxTemperature,
                onTap: () => _sendCommand(
                  _controller.temperatureCommand(
                    state,
                    state.targetTemperature + 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget windCard(BuildContext context, AirconState state, bool busy) {
    final scheme = Theme.of(context).colorScheme;
    return AirconMiCard(
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
          AirconSlidingOptionRow(
            items: [
              for (final speed in AirconWindSpeed.values)
                AirconSlidingOptionItem(
                  letter: switch (speed) {
                    AirconWindSpeed.auto => "A",
                    AirconWindSpeed.silent => "S",
                    AirconWindSpeed.low => "L",
                    AirconWindSpeed.medium => "M",
                    AirconWindSpeed.high => "H",
                  },
                  label: context.t.resolveKey(speed.labelKey),
                  selected: state.windSpeed == speed && !state.strongMode,
                  onTap: () =>
                      _sendCommand(_controller.windSpeedCommand(state, speed)),
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

  Widget swingCard(BuildContext context, AirconState state, bool busy) {
    return AirconMiCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      child: Row(
        children: [
          AirconRoundButton(
            icon: Icons.swap_vert,
            selected: state.verticalSwing,
            accent: Theme.of(context).colorScheme.primary,
            enabled: !busy,
            size: 52,
            onTap: () => _sendCommand(
              _controller.verticalSwingCommand(state, !state.verticalSwing),
            ),
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
            onChanged: busy
                ? null
                : (value) => _sendCommand(
                    _controller.verticalSwingCommand(state, value),
                  ),
          ),
        ],
      ),
    );
  }

  Widget otherCard(BuildContext context, AirconState state, bool busy) {
    Widget row({
      required IconData icon,
      required String label,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return AirconSwitchRow(
        icon: icon,
        label: label,
        value: value,
        enabled: !busy,
        onChanged: onChanged,
      );
    }

    return AirconMiCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Column(
        children: [
          row(
            icon: Icons.bolt_outlined,
            label: context.t.electricity.airconStrongMode,
            value: state.strongMode,
            onChanged: (value) =>
                _sendCommand(_controller.strongModeCommand(state, value)),
          ),
          const Divider(height: 1),
          row(
            icon: Icons.local_fire_department_outlined,
            label: context.t.electricity.airconElectricHeating,
            value: state.electricHeating,
            onChanged: (value) =>
                _sendCommand(_controller.electricHeatingCommand(state, value)),
          ),
        ],
      ),
    );
  }

  Widget modeCard(BuildContext context, AirconState state, bool busy) {
    const order = [
      AirconMode.cool,
      AirconMode.heat,
      AirconMode.auto,
      AirconMode.fan,
      AirconMode.dry,
    ];

    return AirconMiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t.electricity.airconMode,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          AirconSlidingOptionRow(
            items: [
              for (final mode in order)
                AirconSlidingOptionItem(
                  icon: _modeIcon(mode),
                  label: context.t.resolveKey(mode.labelKey),
                  selected: state.mode == mode,
                  onTap: () =>
                      _sendCommand(_controller.modeCommand(state, mode)),
                ),
            ],
            selectedIndex: order.indexOf(state.mode),
            enabled: !busy,
          ),
        ],
      ),
    );
  }

  Widget message(
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
