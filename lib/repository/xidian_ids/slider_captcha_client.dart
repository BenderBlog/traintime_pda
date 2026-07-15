// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MIT

// https://juejin.cn/post/7284608063914622995

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';

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

  static const double _puzzleWidth = 280;
  static const double _puzzleHeight = 155;
  static const double _pieceWidth = 44;
  static const double _pieceHeight = 155;
  Uint8List? _puzzleData;
  Uint8List? _pieceData;
  Uint8List? _aesKey;

  double get puzzleWidth => _puzzleWidth;
  double get puzzleHeight => _puzzleHeight;
  double get pieceWidth => _pieceWidth;
  double get pieceHeight => _pieceHeight;
  Uint8List? get puzzleData => _puzzleData;
  Uint8List? get pieceData => _pieceData;

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
  Future<void> solve({
    Future<bool> Function(SliderCaptchaClientProvider provider)? manualSolver,
  }) async {
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
    if (manualSolver != null && await manualSolver(this)) return;
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
      tracks.add(TrackPoint(a, b, _rng.nextInt(201) + 300));
    }
    tracks.add(TrackPoint(offs, b, _rng.nextInt(201) + 300));
    return tracks;
  }
}

class CaptchaSolveFailedException implements Exception {}
