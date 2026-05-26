// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MIT

// https://juejin.cn/post/7284608063914622995

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image/image.dart' as img;
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';

class Lazy<T> {
  final T Function() _initializer;

  Lazy(this._initializer);

  T? _value;

  T get value => _value ??= _initializer();
}

/// Finger movement track point
class TrackPoint {
  final int a; // x pos
  final int b; // y pos
  final int c; // milliseconds

  TrackPoint(this.a, this.b, this.c);

  Map<String, dynamic> toJson() => {'a': a, 'b': b, 'c': c};
}

class SliderCaptchaClientProvider {
  final String cookie;
  Dio dio = Dio()..interceptors.add(logDioAdapter);

  SliderCaptchaClientProvider({required this.cookie});

  final double _puzzleWidth = 280;
  final double _puzzleHeight = 155;
  final double _pieceWidth = 44;
  final double _pieceHeight = 155;
  Uint8List? _puzzleData;
  Uint8List? _pieceData;
  Lazy<Image>? _puzzleImage;
  Lazy<Image>? _pieceImage;
  Uint8List? _aesKey;

  // fetch and update captcha data
  Future<void> updatePuzzle() async {
    // fetch captcha data
    log.info("Fetching slider captcha...");
    var rsp = await dio.get(
      "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
      options: Options(headers: {"Cookie": cookie}),
    );
    log.info("Captcha fetched, decoding images.");
    // decode base64 and extract aes key
    String puzzleBase64 = rsp.data["bigImage"];
    String pieceBase64 = rsp.data["smallImage"];
    _puzzleData = const Base64Decoder().convert(puzzleBase64);
    _pieceData = const Base64Decoder().convert(pieceBase64);
    _aesKey = _pieceData!.sublist(_pieceData!.length - 16); // key = last 16B
    // update images
    _puzzleImage = Lazy(
      () => Image.memory(
        _puzzleData!,
        width: _puzzleWidth,
        height: _puzzleHeight,
        fit: BoxFit.fitWidth,
      ),
    );
    _pieceImage = Lazy(
      () => Image.memory(
        _pieceData!,
        width: _pieceWidth,
        height: _pieceHeight,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  // submit and verify captcha
  Future<bool> verify(List<TrackPoint> tracks) async {
    final payload = jsonEncode({
      "canvasLength": _puzzleWidth.toInt(),
      "moveLength": tracks.isNotEmpty ? tracks.last.a : 0,
      "tracks": tracks,
    });
    final sign = aesEncrypt(payload, _aesKey!);
    dynamic result = await dio.post(
      "https://ids.xidian.edu.cn/authserver/common/verifySliderCaptcha.htl",
      data: "sign=${Uri.encodeQueryComponent(sign)}",
      options: Options(
        headers: {
          HttpHeaders.acceptHeader:
              "application/json, text/javascript, */*; q=0.01",
          "Cookie": cookie,
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded;charset=UTF-8",
          "Origin": "https://ids.xidian.edu.cn",
          HttpHeaders.accessControlAllowOriginHeader:
              "https://ids.xidian.edu.cn",
          "X-Requested-With": "XMLHttpRequest",
        },
      ),
    );
    log.info("Tried captcha payload:$payload, result:${result.data}");
    return result.data["errorCode"] == 1;
  }

  // solve slider captcha
  Future<void> solve(BuildContext? context) async {
    log.info("Solving slider captcha automatically");
    // multiple tries
    for (int i = 0; i < 6; ++i) {
      // refresh captcha
      await updatePuzzle();
      final offset = solveOffset(_puzzleData!, _pieceData!);
      if (offset == null) throw CaptchaSolveFailedException();
      final int baseMove = (offset * _puzzleWidth).round();
      // try neighboring moves
      for (final delta in [1, -1, 2, -2, 3, -3, 4]) {
        final move = baseMove + delta;
        if (move < 0 || move > _puzzleWidth.toInt()) continue;
        final tracks = generateTracks(move);
        // sleep
        await Future.delayed(
          Duration(milliseconds: max(tracks.last.c - 100, 0)),
        );
        // verify
        try {
          if (await verify(tracks)) return;
        } catch (_) {}
      }
    }
    // fallback to manual solving
    log.info("Solving slider captcha manually");
    if (context != null && context.mounted) {
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => CaptchaWidget(provider: this)),
      );
      if (verified == true) return;
    }
    throw CaptchaSolveFailedException();
  }

  ///
  /// Slider CAPTCHA offset solver
  ///

  // match offset with ncc.
  static double? solveOffset(
    Uint8List puzzleData,
    Uint8List pieceData, {
    int border = 24,
  }) {
    img.Image? puzzle = img.decodeImage(puzzleData);
    if (puzzle == null) return null;
    img.Image? piece = img.decodeImage(pieceData);
    if (piece == null) return null;
    final bbox = _imageBbox(piece);
    var xL = bbox.$1 + border;
    var yT = bbox.$2 + border;
    var xR = bbox.$3 - border;
    var yB = bbox.$4 - border;

    final windowWidth = xR - xL + 1;
    final windowHeight = yB - yT + 1;
    final bigWidth = puzzle.width - piece.width + windowWidth;
    final templateMean =
        _imageSum(piece, xL, yT, windowWidth, windowHeight) /
        (windowWidth * windowHeight);
    final template = _imageNorm(
      piece,
      xL,
      yT,
      windowWidth,
      windowHeight,
      templateMean,
    );
    final columnSums = List<double>.generate(
      bigWidth,
      (x) => _imageSum(puzzle, x + xL, yT, 1, windowHeight),
      growable: false,
    );

    var windowSum = 0.0;
    for (var x = 0; x < windowWidth; x++) {
      windowSum += columnSums[x];
    }
    final area = windowWidth * windowHeight;
    var nccMax = _imageNcc(
      puzzle,
      0 + xL,
      yT,
      windowWidth,
      windowHeight,
      template,
      windowSum / area,
    );
    var xMax = 0;
    for (var x = 1; x < bigWidth - windowWidth; x++) {
      windowSum += columnSums[x + windowWidth - 1] - columnSums[x - 1];
      final ncc = _imageNcc(
        puzzle,
        x + xL,
        yT,
        windowWidth,
        windowHeight,
        template,
        windowSum / area,
      );
      if (ncc > nccMax) {
        nccMax = ncc;
        xMax = x;
      }
    }
    return xMax / puzzle.width;
  }

  // find bbox
  static (int, int, int, int) _imageBbox(img.Image image) {
    var xL = image.width, yT = image.height, xR = 0, yB = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).a.toInt() == 255) {
          if (x < xL) xL = x;
          if (y < yT) yT = y;
          if (x > xR) xR = x;
          if (y > yB) yB = y;
        }
      }
    }
    return (xL, yT, xR, yB);
  }

  // calculate sum of area in an image
  static double _imageSum(
    img.Image image,
    int xL,
    int yT,
    int width,
    int height,
  ) {
    double sum = 0;
    for (var y = yT; y < yT + height; y++) {
      for (var x = xL; x < xL + width; x++) {
        sum += image.getPixel(x, y).luminance;
      }
    }
    return sum;
  }

  // normalize area in an image
  static List<double> _imageNorm(
    img.Image image,
    int xL,
    int yT,
    int width,
    int height,
    double mean,
  ) {
    return [
      for (var y = yT; y < yT + height; y++)
        for (var x = xL; x < xL + width; x++)
          image.getPixel(x, y).luminance - mean,
    ];
  }

  // calculate ncc of area in an image with a template
  static double _imageNcc(
    img.Image window,
    int xL,
    int yT,
    int width,
    int height,
    List<double> template,
    double meanW,
  ) {
    double sumWt = 0, sumWw = 0.000001;
    var iT = template.iterator;
    for (var y = yT; y < yT + height; y++) {
      for (var x = xL; x < xL + width; x++) {
        iT.moveNext();
        var w = window.getPixel(x, y).luminance - meanW;
        sumWt += w * iT.current;
        sumWw += w * w;
      }
    }
    return sumWt / sumWw;
  }

  ///
  /// Finger move track generation
  ///

  static final _rng = Random();
  static final _genTracksNorm = 1.0 / (1.0 + exp(-7.0 * (1.0 - 0.42)));

  // generate track along an skewed sigmoid curve
  static List<TrackPoint> generateTracks(int offs) {
    final tracks = <TrackPoint>[TrackPoint(0, 0, 0)];
    final int n = _rng.nextInt(5) + 10;
    int b = 0;
    for (int i = 0; i < n; i++) {
      // horizontal
      final double z =
          (1.0 / (1.0 + exp(-7.0 * ((i / n) - 0.42)))) / _genTracksNorm;
      final int a = min(offs - 1, max(tracks.last.a + 1, (offs * z).round()));
      // vertical
      final double r = _rng.nextDouble();
      b = ((r < 0.65) ? (b - 1) : ((r < 0.80) ? (b + 1) : (b)));
      b = max(-10, min(10, b));
      tracks.add(TrackPoint(a, b, _rng.nextInt(701) + 900));
    }
    tracks.add(TrackPoint(offs, b, _rng.nextInt(701) + 900));
    return tracks;
  }
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
    final pw = provider._puzzleWidth;
    final ph = provider._puzzleHeight;
    return Column(
      children: [
        SizedBox(
          width: pw,
          height: ph,
          child: Stack(
            alignment: Alignment.center,
            children: [
              provider._puzzleImage!.value,
              Positioned(
                left: _sliderLeftPx,
                child: provider._pieceImage!.value,
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

class CaptchaSolveFailedException implements Exception {}
