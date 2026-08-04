// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MIT

// https://juejin.cn/post/7284608063914622995

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypter_plus/encrypter_plus.dart' as encrypt;
import 'package:image/image.dart' as img;
import 'package:watermeter/repository/logger.dart';

/// 轨迹点模型
class TrackPoint {
  final int a; // x 轴位移
  final int b; // y 轴位移
  final int c; // 时间戳 (毫秒)

  TrackPoint(this.a, this.b, this.c);

  Map<String, dynamic> toJson() => {'a': a, 'b': b, 'c': c};
}

class SliderCaptchaClientProvider {
  static const int _captchaKeySize = 16;
  static const String _captchaPayloadPrefix =
      '................................................................';
  static final Random _random = Random.secure();

  final String cookie;
  Dio dio = Dio()..interceptors.add(logDioAdapter);

  static int solveSlideOffsetForTesting({
    required Uint8List puzzleBytes,
    required Uint8List pieceBytes,
    int border = 24,
  }) {
    final puzzle = img.decodeImage(puzzleBytes);
    final piece = img.decodeImage(pieceBytes);
    if (puzzle == null || piece == null) {
      throw CaptchaSolveFailedException();
    }
    return _solveSlideOffset(puzzle, piece, border);
  }

  static String encryptCaptchaPayloadForTesting(
    String payload,
    Uint8List keyBytes,
  ) => _encryptCaptchaPayload(payload, keyBytes);

  static int _solveSlideOffset(img.Image puzzle, img.Image piece, int border) {
    final bbox = _nrgbaBbox(piece);
    var xL = bbox.$1 + border;
    var yT = bbox.$2 + border;
    var xR = bbox.$3 - border;
    var yB = bbox.$4 - border;
    if (xL < 0 || yT < 0 || xR < xL || yB < yT) {
      throw CaptchaSolveFailedException();
    }

    final windowWidth = xR - xL + 1;
    final windowHeight = yB - yT + 1;
    final bigWidth = puzzle.width - piece.width + windowWidth;
    if (windowWidth <= 0 ||
        windowHeight <= 0 ||
        bigWidth < windowWidth ||
        xL + windowWidth > piece.width ||
        yT + windowHeight > piece.height ||
        xL + bigWidth > puzzle.width ||
        yT + windowHeight > puzzle.height) {
      throw CaptchaSolveFailedException();
    }

    final templateGray = _grayFromImage(
      piece,
      xL,
      yT,
      windowWidth,
      windowHeight,
    );
    final templateMean =
        _graySum(templateGray, 0, 0, windowWidth, windowHeight) /
        (windowWidth * windowHeight);
    final template = _grayNorm(
      templateGray,
      0,
      0,
      windowWidth,
      windowHeight,
      templateMean,
    );
    final puzzleGray = _grayFromImage(puzzle, xL, yT, bigWidth, windowHeight);
    final columnSums = List<double>.generate(
      bigWidth,
      (x) => _graySum(puzzleGray, x, 0, 1, windowHeight),
      growable: false,
    );

    var windowSum = 0.0;
    for (var x = 0; x < windowWidth; x++) {
      windowSum += columnSums[x];
    }
    final area = windowWidth * windowHeight;
    var maxScore = _grayNccFast(
      puzzleGray,
      0,
      0,
      windowWidth,
      windowHeight,
      windowSum / area,
      template,
    );
    var bestX = 0;
    for (var x = 1; x < bigWidth - windowWidth; x++) {
      windowSum += columnSums[x + windowWidth - 1] - columnSums[x - 1];
      final score = _grayNccFast(
        puzzleGray,
        x,
        0,
        windowWidth,
        windowHeight,
        windowSum / area,
        template,
      );
      if (score > maxScore) {
        maxScore = score;
        bestX = x;
      }
    }
    return bestX;
  }

  static (int, int, int, int) _nrgbaBbox(img.Image image) {
    var xL = image.width;
    var yT = image.height;
    var xR = 0;
    var yB = 0;
    var found = false;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).a.toInt() == 255) {
          found = true;
          if (x < xL) xL = x;
          if (y < yT) yT = y;
          if (x > xR) xR = x;
          if (y > yB) yB = y;
        }
      }
    }
    if (!found) throw CaptchaSolveFailedException();
    return (xL, yT, xR, yB);
  }

  static ({List<int> pixels, int stride}) _grayFromImage(
    img.Image image,
    int xL,
    int yT,
    int width,
    int height,
  ) {
    final pixels = List<int>.filled(width * height, 0, growable: false);
    var index = 0;
    for (var y = yT; y < yT + height; y++) {
      for (var x = xL; x < xL + width; x++) {
        final pixel = image.getPixel(x, y);
        pixels[index++] =
            (77 * pixel.r.toInt() +
                150 * pixel.g.toInt() +
                29 * pixel.b.toInt()) >>
            8;
      }
    }
    return (pixels: pixels, stride: width);
  }

  static double _graySum(
    ({List<int> pixels, int stride}) gray,
    int xL,
    int yT,
    int width,
    int height,
  ) {
    var sum = 0.0;
    for (var y = yT; y < yT + height; y++) {
      final rowOffset = y * gray.stride;
      for (var x = xL; x < xL + width; x++) {
        sum += gray.pixels[rowOffset + x];
      }
    }
    return sum;
  }

  static List<double> _grayNorm(
    ({List<int> pixels, int stride}) gray,
    int xL,
    int yT,
    int width,
    int height,
    double mean,
  ) {
    final normalized = List<double>.filled(width * height, 0, growable: false);
    var index = 0;
    for (var y = yT; y < yT + height; y++) {
      final rowOffset = y * gray.stride;
      for (var x = xL; x < xL + width; x++) {
        normalized[index++] = gray.pixels[rowOffset + x] - mean;
      }
    }
    return normalized;
  }

  static double _grayNccFast(
    ({List<int> pixels, int stride}) windowImage,
    int xL,
    int yT,
    int width,
    int height,
    double mean,
    List<double> template,
  ) {
    var sumWindowTemplate = 0.0;
    var sumWindowWindow = 0.0;
    var index = 0;
    for (var y = yT; y < yT + height; y++) {
      final rowOffset = y * windowImage.stride;
      for (var x = xL; x < xL + width; x++) {
        final window = windowImage.pixels[rowOffset + x] - mean;
        sumWindowWindow += window * window;
        sumWindowTemplate += window * template[index++];
      }
    }
    if (sumWindowWindow == 0) return double.negativeInfinity;
    return sumWindowTemplate / sumWindowWindow;
  }

  static List<TrackPoint> _generateAutoTracks(int targetX) {
    if (targetX <= 0) {
      return [TrackPoint(0, 0, 0), TrackPoint(0, 0, 0)];
    }
    const norm = 1.0 / (1.0 + 0.017248380016648118);
    final tracks = [TrackPoint(0, 0, 0)];
    final pointCount = _random.nextInt(5) + 10;
    var y = 0;
    for (var i = 0; i < pointCount; i++) {
      final z = (1.0 / (1.0 + exp(-7.0 * (i / pointCount - 0.42)))) / norm;
      final previousX = tracks.last.a;
      final x = min(targetX - 1, max(previousX + 1, (targetX * z).round()));
      final drift = _random.nextDouble();
      if (drift < 0.65) {
        y--;
      } else if (drift < 0.80) {
        y++;
      }
      y = max(-10, min(10, y));
      tracks.add(TrackPoint(x, y, _random.nextInt(701) + 900));
    }
    tracks.add(TrackPoint(targetX, y, _random.nextInt(701) + 900));
    return tracks;
  }

  static String _encryptCaptchaPayload(String payload, Uint8List keyBytes) {
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromUtf8('................');
    final aes = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    return aes.encrypt('$_captchaPayloadPrefix$payload', iv: iv).base64;
  }

  Future<bool> _solveAutomatically() async {
    await updatePuzzle();
    final puzzle = img.decodeImage(puzzleData!);
    final piece = img.decodeImage(pieceData!);
    if (puzzle == null || piece == null) return false;
    final solvedOffset = _solveSlideOffset(puzzle, piece, 24);
    final baseMove = solvedOffset * puzzleWidth.toInt() ~/ puzzle.width;
    for (final delta in const [1, -1, 2, -2, 3, -3, 4]) {
      final move = baseMove + delta;
      if (move < 0 || move > puzzleWidth) continue;
      final tracks = _generateAutoTracks(move);
      await Future<void>.delayed(
        Duration(milliseconds: max(0, tracks.last.c - 100)),
      );
      if (await verifyWithTracks(tracks)) return true;
    }
    return false;
  }

  SliderCaptchaClientProvider({required this.cookie});

  Uint8List? puzzleData;
  Uint8List? pieceData;

  final double puzzleWidth = 280;

  Future<void> updatePuzzle() async {
    log.info("Fetching slider captcha...");
    var rsp = await dio.get(
      "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
      options: Options(headers: {"Cookie": cookie}),
    );
    log.info("Captcha fetched, decoding images.");

    String puzzleBase64 = rsp.data["bigImage"];
    String pieceBase64 = rsp.data["smallImage"];
    // double coordinatesY = double.parse(rsp.data["tagWidth"].toString());

    puzzleData = const Base64Decoder().convert(puzzleBase64);
    pieceData = const Base64Decoder().convert(pieceBase64);
  }

  Future<void> solveAutomatically() async {
    log.info('Trying automatic slider captcha solve.');
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        if (await _solveAutomatically()) return;
      } catch (error, stackTrace) {
        log.warning(
          'Automatic slider captcha solve failed.',
          error,
          stackTrace,
        );
        if (attempt < 4) {
          await Future<void>.delayed(Duration(seconds: attempt + 1));
        }
      }
    }
    throw CaptchaSolveFailedException();
  }

  Future<bool> verifyWithTracks(List<TrackPoint> tracks) async {
    final moveLength = tracks.isNotEmpty ? tracks.last.a : 0;
    final payload = jsonEncode({
      "canvasLength": puzzleWidth.toInt(),
      "moveLength": moveLength,
      "tracks": tracks,
    });
    log.info(
      "Verify captcha with ${tracks.length} track points "
      "(moveLength=$moveLength).",
    );
    final sign = _encryptPayload(payload);

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
    log.info("Verify response: ${result.data}");
    return result.data["errorMsg"] == "success" ||
        result.data["errorCode"] == 1;
  }

  String _encryptPayload(String payload) {
    if (pieceData == null || pieceData!.length < _captchaKeySize) {
      throw StateError("Captcha image is too short to contain AES key.");
    }

    return _encryptCaptchaPayload(
      payload,
      pieceData!.sublist(pieceData!.length - _captchaKeySize),
    );
  }
}

class CaptchaSolveFailedException implements Exception {}
