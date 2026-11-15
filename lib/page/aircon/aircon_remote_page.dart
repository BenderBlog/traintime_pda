// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/services.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/aircon_imei_page.dart';
import 'package:watermeter/repository/miscellaneous_session/aircon_session.dart';

import 'package:watermeter/page/aircon/aircon_remote_cards.dart';
import 'package:watermeter/page/aircon/aircon_remote_widgets.dart';

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
        throw const AirconResponseException("device owner mismatch");
      }

      final matches = _pendingMatches;
      if (matches != null && !matches(state)) {
        setState(() {
          _error = const AirconResponseException(
            "device state still unconfirmed",
          );
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

  Future<void> _sendCommand(AirconRemoteCommand? command) async {
    final imei = _controller.imeiSignal.value;
    final previous = _state;
    if (command == null ||
        imei.isEmpty ||
        previous == null ||
        _pendingMatches != null ||
        _isFetching) {
      return;
    }
    final generation = ++_generation;

    HapticFeedback.selectionClick();
    setState(() {
      _state = command.optimisticState;
      _error = null;
      _isFetching = true;
      _pendingMatches = command.matches;
    });

    try {
      final confirmedState = await _controller.sendRemoteCommand(
        imei: imei,
        command: command,
        isCurrent: () => mounted && generation == _generation,
      );
      if (!mounted ||
          generation != _generation ||
          imei != _controller.imeiSignal.value ||
          confirmedState == null) {
        return;
      }
      setState(() {
        _state = confirmedState;
        _error = null;
        _isFetching = false;
        _pendingMatches = null;
      });
      _controller.setDeviceState(confirmedState);
      showToast(context: context, msg: context.t.electricity.airconCommandOk);
    } on AirconCommandException catch (error) {
      if (!mounted ||
          generation != _generation ||
          imei != _controller.imeiSignal.value) {
        return;
      }
      setState(() {
        _error = error.error;
        _isFetching = false;
        _pendingMatches = null;
        if (!error.sent) _state = previous;
      });
      showToast(
        context: context,
        msg: context.t.electricity.airconControlError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      body: SignalBuilder(
        builder: (context) {
          final cards = AirconRemoteCards(
            controller: _controller,
            state: _state,
            isFetching: _isFetching,
            onRefresh: _refreshDeviceState,
            onCommand: _sendCommand,
          );
          if (_controller.imeiSignal.value.isEmpty) {
            return AirconRemotePlaceholder(
              child: cards.message(
                context,
                context.t.electricity.airconImeiMissing,
                onPressed: _configure,
                actionLabel: context.t.electricity.airconAddImei,
                actionIcon: Icons.settings_outlined,
              ),
            );
          }

          final state = _state;
          if (state == null) {
            if (_error != null) {
              return AirconRemotePlaceholder(
                child: cards.message(
                  context,
                  context.t.electricity.airconControlError,
                  details: _error.toString(),
                  onPressed: _refreshDeviceState,
                ),
              );
            }
            return const AirconRemotePlaceholder(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final busy = _isFetching || _pendingMatches != null;
          final gradient = cards.gradientColors(context, state);

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
                    leading: const BackButton(),
                    actions: [
                      AirconPressScaleFeedback(
                        child: IconButton(
                          onPressed: _isFetching ? null : _refreshDeviceState,
                          tooltip: context.t.electricity.update,
                          color: scheme.onSurfaceVariant,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                      AirconPressScaleFeedback(
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
                          duration: stateMotionDuration,
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
                              child: cards.hero(context, state, expansion),
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
                          AirconCardEntrance(
                            index: 1,
                            child: cards.errorCard(context, _error!),
                          ),
                        AirconCardEntrance(
                          index: 2,
                          child: cards.energyCard(context),
                        ),
                        AirconCardEntrance(
                          index: 3,
                          child: cards.powerCard(context, state, busy),
                        ),
                        AirconCardEntrance(
                          index: 4,
                          child: cards.temperatureCard(context, state, busy),
                        ),
                        AirconCardEntrance(
                          index: 5,
                          child: cards.windCard(context, state, busy),
                        ),
                        AirconCardEntrance(
                          index: 6,
                          child: cards.swingCard(context, state, busy),
                        ),
                        AirconCardEntrance(
                          index: 7,
                          child: cards.otherCard(context, state, busy),
                        ),
                        AirconCardEntrance(
                          index: 8,
                          child: cards.modeCard(context, state, busy),
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
}
