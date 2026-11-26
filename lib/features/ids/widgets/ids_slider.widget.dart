// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MIT

import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:watermeter/generated/translations.g.dart';

Future<List<IdsSliderPoint>?> showIdsSlider(
  BuildContext context,
  Uint8List background,
  Uint8List piece, {
  bool retry = false,
}) => Navigator.of(context).push<List<IdsSliderPoint>>(
  MaterialPageRoute(
    builder: (context) =>
        _IdsSliderPage(background: background, piece: piece, retry: retry),
  ),
);

class _IdsSliderPage extends StatefulWidget {
  const _IdsSliderPage({
    required this.background,
    required this.piece,
    required this.retry,
  });

  final Uint8List background;
  final Uint8List piece;
  final bool retry;

  @override
  State<_IdsSliderPage> createState() => _IdsSliderPageState();
}

class _IdsSliderPageState extends State<_IdsSliderPage> {
  static const double _width = 280;
  static const double _height = 155;
  static const double _handleSize = 42;
  static const double _rightPadding = 40;
  static const int _recordIntervalMs = 20;
  static const double _recordDistancePx = 2;
  int? _activePointer;
  Offset? _dragStart;
  double _sliderLeft = 0;
  final _points = <IdsSliderPoint>[];
  DateTime? _lastTime;
  int? _lastTrackA;
  int? _lastTrackB;

  void _onPointerDown(PointerDownEvent event) {
    final handleLeft = (_sliderLeft - 1).clamp(0, _width - _handleSize);
    if (_activePointer != null ||
        event.localPosition.dx < handleLeft ||
        event.localPosition.dx > handleLeft + _handleSize ||
        event.localPosition.dy < 0 ||
        event.localPosition.dy > _handleSize) {
      return;
    }
    _activePointer = event.pointer;
    _dragStart = event.position;
    _lastTime = DateTime.now();
    _lastTrackA = null;
    _lastTrackB = null;
    _points.clear();
    _points.add((x: 0, y: 0, milliseconds: 0));
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_activePointer != event.pointer) return;
    final start = _dragStart;
    final lastTime = _lastTime;
    if (start == null || lastTime == null) return;
    final dx = event.position.dx - start.dx;
    if (dx < 0 || dx + _rightPadding > _width) return;
    final now = DateTime.now();
    final dy = event.position.dy - start.dy;
    final elapsed = now.difference(lastTime).inMilliseconds;
    setState(() => _sliderLeft = dx.clamp(0, _width - _rightPadding));
    if (elapsed < _recordIntervalMs) return;
    final a = dx.round();
    final b = dy.round();
    final lastA = _lastTrackA;
    final lastB = _lastTrackB;
    if (lastA != null && lastB != null) {
      final distanceSquared =
          (a - lastA) * (a - lastA) + (b - lastB) * (b - lastB);
      if (distanceSquared < _recordDistancePx * _recordDistancePx) return;
    }
    _points.add((x: a, y: b, milliseconds: elapsed));
    _lastTrackA = a;
    _lastTrackB = b;
    _lastTime = now;
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_activePointer != event.pointer) return;
    final start = _dragStart;
    final lastTime = _lastTime;
    _activePointer = null;
    _dragStart = null;
    if (start == null || lastTime == null) return;
    final dx = event.position.dx - start.dx;
    if (dx == 0) return;
    final dy = event.position.dy - start.dy;
    final elapsed = DateTime.now().difference(lastTime).inMilliseconds;
    _points.add((x: dx.round(), y: dy.round(), milliseconds: elapsed));
    setState(() => _sliderLeft = dx.clamp(0, _width - _rightPadding));
    Navigator.of(context).pop(List<IdsSliderPoint>.unmodifiable(_points));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t.ids.sliderTitle)),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.retry) Text(context.t.ids.sliderRetry),
          SizedBox(
            width: _width,
            height: _height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  widget.background,
                  width: _width,
                  height: _height,
                  fit: BoxFit.fitWidth,
                ),
                Positioned(
                  left: _sliderLeft,
                  child: Image.memory(
                    widget.piece,
                    height: _height,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ],
            ),
          ),
          Listener(
            key: const ValueKey('ids-slider-track'),
            behavior: HitTestBehavior.opaque,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: (event) {
              if (event.pointer == _activePointer) {
                _activePointer = null;
                _dragStart = null;
                _lastTime = null;
                _lastTrackA = null;
                _lastTrackB = null;
              }
            },
            child: SizedBox(
              width: _width,
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    top: 17,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green[900],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 17,
                    left: 0,
                    width: _sliderLeft + 4,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (_sliderLeft - 1).clamp(0, _width - _handleSize),
                    top: 1,
                    child: Container(
                      width: _handleSize,
                      height: _handleSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
