// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MIT

// https://juejin.cn/post/7284608063914622995

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/slider_captcha_client.dart';

Future<bool> solveSliderCaptchaManually(
  BuildContext context,
  SliderCaptchaClientProvider provider,
) async {
  if (!context.mounted) return false;
  return await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CaptchaWidget(provider: provider),
        ),
      ) ==
      true;
}

class CaptchaWidget extends StatefulWidget {
  final SliderCaptchaClientProvider provider;

  const CaptchaWidget({super.key, required this.provider});

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  static const double _sliderHandleSize = 42;
  static const double _jsSliderRightPadding = 40;
  static const int _recordIntervalMs = 20;
  static const double _recordDistancePx = 2;

  late Future<SliderCaptchaClientProvider> _providerFuture;

  final List<TrackPoint> _tracks = [];
  DateTime? _lastRecordTime;
  Offset? _dragStartGlobal;
  int? _activePointer;
  int? _lastTrackA;
  int? _lastTrackB;

  double _sliderLeftPx = 0;
  bool _isSubmitting = false;
  String? _statusText;

  @override
  void initState() {
    super.initState();
    updateProvider();
  }

  void updateProvider({String? statusText}) {
    _sliderLeftPx = 0;
    _tracks.clear();
    _lastRecordTime = null;
    _dragStartGlobal = null;
    _activePointer = null;
    _lastTrackA = null;
    _lastTrackB = null;
    _isSubmitting = false;
    _statusText = statusText;
    _providerFuture = widget.provider.updatePuzzle().then((value) {
      return widget.provider;
    });
  }

  double _dragLimit(double puzzleWidth) {
    return max(0, puzzleWidth - _jsSliderRightPadding).toDouble();
  }

  double _thumbLeft(double puzzleWidth) {
    return (_sliderLeftPx - 1)
        .clamp(0.0, max(0, puzzleWidth - _sliderHandleSize))
        .toDouble();
  }

  bool _isInsideThumb(Offset localPosition, double puzzleWidth) {
    final left = _thumbLeft(puzzleWidth);
    return localPosition.dx >= left &&
        localPosition.dx <= left + _sliderHandleSize &&
        localPosition.dy >= 0 &&
        localPosition.dy <= _sliderHandleSize;
  }

  void _onPointerDown(PointerDownEvent event, double puzzleWidth) {
    if (_isSubmitting || _activePointer != null) return;
    if (!_isInsideThumb(event.localPosition, puzzleWidth)) return;

    _activePointer = event.pointer;
    _dragStartGlobal = event.position;
    _lastRecordTime = DateTime.now();
    _lastTrackA = null;
    _lastTrackB = null;
    _tracks.clear();
    _tracks.add(TrackPoint(0, 0, 0));
    if (_statusText != null) {
      setState(() => _statusText = null);
    }
  }

  void _onPointerMove(PointerMoveEvent event, double puzzleWidth) {
    if (event.pointer != _activePointer) return;
    final start = _dragStartGlobal;
    final lastTime = _lastRecordTime;
    if (start == null || lastTime == null) return;

    final dx = event.position.dx - start.dx;
    if (dx < 0 || dx + _jsSliderRightPadding > puzzleWidth) return;

    final now = DateTime.now();
    final dy = event.position.dy - start.dy;
    final elapsed = now.difference(lastTime).inMilliseconds;

    setState(() => _sliderLeftPx = dx.clamp(0.0, _dragLimit(puzzleWidth)));

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

    _tracks.add(TrackPoint(a, b, elapsed));
    _lastTrackA = a;
    _lastTrackB = b;
    _lastRecordTime = now;
  }

  Future<void> _onPointerUp(PointerUpEvent event, double puzzleWidth) async {
    if (event.pointer != _activePointer) return;
    await _finishDrag(event.position, puzzleWidth);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    _dragStartGlobal = null;
    _lastRecordTime = null;
    _lastTrackA = null;
    _lastTrackB = null;
  }

  Future<void> _finishDrag(Offset globalPosition, double puzzleWidth) async {
    final start = _dragStartGlobal;
    final lastTime = _lastRecordTime;
    _activePointer = null;
    _dragStartGlobal = null;

    if (start == null || lastTime == null) return;

    final dx = globalPosition.dx - start.dx;
    if (dx == 0) return;

    final dy = globalPosition.dy - start.dy;
    final elapsed = DateTime.now().difference(lastTime).inMilliseconds;
    _tracks.add(TrackPoint(dx.round(), dy.round(), elapsed));
    log.info("Recorded ${_tracks.length} real slider track points.");

    setState(() {
      _sliderLeftPx = dx.clamp(0.0, _dragLimit(puzzleWidth));
      _isSubmitting = true;
    });

    try {
      final verified = await widget.provider.verify(_tracks);
      if (!mounted) return;
      if (verified) {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        updateProvider(statusText: "再试一次");
      });
    } catch (e, s) {
      log.warning("Slider captcha verify failed: $e\n$s");
      if (!mounted) return;
      setState(() {
        updateProvider(statusText: "再试一次");
      });
    }
  }

  Widget _buildSlider(double puzzleWidth) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _onPointerDown(event, puzzleWidth),
      onPointerMove: (event) => _onPointerMove(event, puzzleWidth),
      onPointerUp: (event) => _onPointerUp(event, puzzleWidth),
      onPointerCancel: _onPointerCancel,
      child: SizedBox(
        width: puzzleWidth,
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
              width: (_sliderLeftPx + 4).clamp(0.0, puzzleWidth).toDouble(),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Positioned(
              left: _thumbLeft(puzzleWidth),
              top: 1,
              child: Container(
                width: _sliderHandleSize,
                height: _sliderHandleSize,
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
                child: _isSubmitting
                    ? const Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.green[900],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptcha(SliderCaptchaClientProvider provider) {
    final pw = provider.puzzleWidth;
    final ph = provider.puzzleHeight;
    return Column(
      children: [
        SizedBox(
          width: pw,
          height: ph,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.memory(
                provider.puzzleData!,
                width: provider.puzzleWidth,
                height: provider.puzzleHeight,
                fit: BoxFit.fitWidth,
              ),
              Positioned(
                left: _sliderLeftPx,
                child: Image.memory(
                  provider.pieceData!,
                  width: provider.pieceWidth,
                  height: provider.pieceHeight,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
        _buildSlider(pw),
        if (_statusText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _statusText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ).center();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "login.slider_title")),
      ),
      body: FutureBuilder<SliderCaptchaClientProvider>(
        future: _providerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    updateProvider(statusText: "Try Again");
                  });
                },
                icon: const Icon(Icons.refresh),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildCaptcha(snapshot.data!);
        },
      ),
    );
  }
}
