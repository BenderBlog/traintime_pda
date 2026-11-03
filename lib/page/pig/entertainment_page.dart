// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/external/guess_book/guess_book.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/pig/pig_page.dart';

/// 猪图鉴赏与猜书名共用的导航页。
class EntertainmentPage extends StatelessWidget {
  const EntertainmentPage({super.key, this.parentPageController});

  /// 外层主页控制器，用于在首尾标签继续拖动时切换主页。
  final PageController? parentPageController;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.homepage.relax),
          bottom: TabBar(
            tabs: [
              Tab(text: context.t.homepage.dashboard),
              Tab(text: context.t.guessBook.title),
            ],
            onTap: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
        ),
        body: _EdgePageHandoff(
          parentController: parentPageController,
          child: const TabBarView(
            children: [
              PigPage(showAppBar: false),
              GuessBookPage(showAppBar: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// 首尾标签向外拖动时，将同一次拖动交给外层 PageView。
class _EdgePageHandoff extends StatefulWidget {
  const _EdgePageHandoff({required this.parentController, required this.child});

  final PageController? parentController;
  final Widget child;

  @override
  State<_EdgePageHandoff> createState() => _EdgePageHandoffState();
}

class _EdgePageHandoffState extends State<_EdgePageHandoff> {
  int? _pointer;
  Offset? _start;
  VelocityTracker? _velocity;
  Drag? _parentDrag;
  bool _decided = false;

  void _onDown(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _start = event.position;
    _decided = false;
    _velocity = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _onMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    _velocity?.addPosition(event.timeStamp, event.position);
    var delta = event.delta.dx;
    if (!_decided) {
      final distance = event.position - _start!;
      if (distance.distance < kTouchSlop) return;
      _decided = true;
      if (distance.dx.abs() <= distance.dy.abs()) return;

      final tabs = DefaultTabController.of(context);
      final tabPosition = tabs.animation?.value ?? tabs.index.toDouble();
      final atFirst = tabPosition.abs() < 0.001;
      final atLast = (tabPosition - (tabs.length - 1)).abs() < 0.001;
      final parent = widget.parentController;
      final outward =
          (atFirst && distance.dx > 0) || (atLast && distance.dx < 0);
      if (!outward || parent == null || !parent.hasClients) return;

      final position = parent.position;
      if ((distance.dx > 0 && position.pixels <= position.minScrollExtent) ||
          (distance.dx < 0 && position.pixels >= position.maxScrollExtent)) {
        return;
      }
      FocusManager.instance.primaryFocus?.unfocus();
      _parentDrag = position.drag(
        DragStartDetails(globalPosition: _start!, kind: event.kind),
        () => _parentDrag = null,
      );
      delta = distance.dx;
    }
    _parentDrag?.update(
      DragUpdateDetails(
        globalPosition: event.position,
        sourceTimeStamp: event.timeStamp,
        kind: event.kind,
        delta: Offset(delta, 0),
        primaryDelta: delta,
      ),
    );
  }

  void _onUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    _velocity?.addPosition(event.timeStamp, event.position);
    final rawSpeed = _velocity?.getVelocity().pixelsPerSecond.dx ?? 0;
    final parent = widget.parentController;
    final physics = parent != null && parent.hasClients
        ? parent.position.physics
        : null;
    final speed = physics == null || rawSpeed.abs() < physics.minFlingVelocity
        ? 0.0
        : rawSpeed.clamp(-physics.maxFlingVelocity, physics.maxFlingVelocity);
    _parentDrag?.end(
      DragEndDetails(
        globalPosition: event.position,
        velocity: Velocity(pixelsPerSecond: Offset(speed, 0)),
        primaryVelocity: speed,
      ),
    );
    _reset();
  }

  void _reset() {
    _pointer = null;
    _start = null;
    _velocity = null;
    _parentDrag = null;
    _decided = false;
  }

  @override
  void dispose() {
    _parentDrag?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _onDown,
    onPointerMove: _onMove,
    onPointerUp: _onUp,
    onPointerCancel: (event) {
      if (event.pointer != _pointer) return;
      _parentDrag?.cancel();
      _reset();
    },
    child: widget.child,
  );
}
