// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MIT

// https://juejin.cn/post/7284608063914622995

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image/image.dart' as img;
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/repository/logger.dart';

class Lazy<T> {
  final T Function() _initializer;

  Lazy(this._initializer);

  T? _value;

  T get value => _value ??= _initializer();
}

class SliderCaptchaClientProvider {
  final String cookie;
  Dio dio = Dio()..interceptors.add(logDioAdapter);

  SliderCaptchaClientProvider({required this.cookie});

  Uint8List? puzzleData;
  Uint8List? pieceData;
  Lazy<Image>? puzzleImage;
  Lazy<Image>? pieceImage;

  final double puzzleWidth = 280;
  final double puzzleHeight = 155;
  final double pieceWidth = 44;
  final double pieceHeight = 155;

  Future<void> updatePuzzle() async {
    var rsp = await dio.get(
      "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
      options: Options(headers: {"Cookie": cookie}),
    );

    String puzzleBase64 = rsp.data["bigImage"];
    String pieceBase64 = rsp.data["smallImage"];
    // double coordinatesY = double.parse(rsp.data["tagWidth"].toString());

    puzzleData = const Base64Decoder().convert(puzzleBase64);
    pieceData = const Base64Decoder().convert(pieceBase64);

    puzzleImage = Lazy(() => Image.memory(puzzleData!,
        width: puzzleWidth, height: puzzleHeight, fit: BoxFit.fitWidth));
    pieceImage = Lazy(() => Image.memory(pieceData!,
        width: pieceWidth, height: pieceHeight, fit: BoxFit.fitWidth));
  }

  Future<void> solve(BuildContext? context, {int retryCount = 20}) async {
    for (int i = 0; i < retryCount; i++) {
      await updatePuzzle();
      double? answer = _trySolve(puzzleData!, pieceData!);
      if (answer != null && await verify(answer)) {
        log.info("Parse captcha $i time(s), success.");
        return;
      }
      log.info("Parse captcha $i time(s), failure.");
    }

    log.info("$retryCount failures, fallback to user input.");
    // fallback
    if (context != null && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CaptchaWidget(provider: this),
        ),
      );
    }
    throw CaptchaSolveFailedException();
  }

  Future<bool> verify(double answer) async {
    dynamic result = await dio.post(
      "https://ids.xidian.edu.cn/authserver/common/verifySliderCaptcha.htl",
      data:
          "canvasLength=${(puzzleWidth)}&moveLength=${(answer * puzzleWidth).toInt()}",
      options: Options(
        headers: {
          "Cookie": cookie,
          HttpHeaders.contentTypeHeader:
              "application/x-www-form-urlencoded;charset=utf-8",
          HttpHeaders.accessControlAllowOriginHeader:
              "https://ids.xidian.edu.cn",
        },
      ),
    );
    return result.data["errorCode"] == 1;
  }

  static double? _trySolve(Uint8List puzzleData, Uint8List pieceData,
      {int border = 24}) {
    img.Image? puzzle = img.decodeImage(puzzleData);
    if (puzzle == null) {
      return null;
    }
    img.Image? piece = img.decodeImage(pieceData);
    if (piece == null) {
      return null;
    }

    var bbox = _findAlphaBoundingBox(piece);
    var xL = bbox[0] + border,
        yT = bbox[1] + border,
        xR = bbox[2] - border,
        yB = bbox[3] - border;

    var widthW = xR - xL, heightW = yB - yT, lenW = widthW * heightW;
    var widthG = puzzle.width - piece.width + widthW - 1;

    var meanT = _calculateMean(piece, xL, yT, widthW, heightW);
    var templateN = _normalizeImage(piece, xL, yT, widthW, heightW, meanT);
    var colsW = [
      for (var x = xL + 1; x < widthG + 1; ++x)
        _calculateSum(puzzle, x, yT, 1, heightW)
    ];
    var colsWL = colsW.iterator, colsWR = colsW.iterator;
    double sumW = 0;
    for (var i = 0; i < widthW; ++i) {
      colsWR.moveNext();
      sumW += colsWR.current;
    }
    double nccMax = 0;
    int xMax = 0;
    for (var x = xL + 1; x < widthG - widthW; x += 2) {
      colsWL.moveNext();
      colsWR.moveNext();
      sumW = sumW - colsWL.current + colsWR.current;
      colsWL.moveNext();
      colsWR.moveNext();
      sumW = sumW - colsWL.current + colsWR.current;
      var ncc =
          _calculateNCC(puzzle, x, yT, widthW, heightW, templateN, sumW / lenW);
      if (ncc > nccMax) {
        nccMax = ncc;
        xMax = x;
      }
    }

    return (xMax - xL - 1) / puzzle.width;
  }

  static List<int> _findAlphaBoundingBox(img.Image image) {
    var xL = image.width, yT = image.height, xR = 0, yB = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).a != 255) continue;
        if (x < xL) xL = x;
        if (y < yT) yT = y;
        if (x > xR) xR = x;
        if (y > yB) yB = y;
      }
    }
    return [xL, yT, xR, yB];
  }

  static double _calculateSum(
      img.Image image, int x, int y, int width, int height) {
    double sum = 0;
    for (var yy = y; yy < y + height; yy++) {
      for (var xx = x; xx < x + width; xx++) {
        sum += image.getPixel(xx, yy).luminance;
      }
    }
    return sum;
  }

  static double _calculateMean(
      img.Image image, int x, int y, int width, int height) {
    return _calculateSum(image, x, y, width, height) / width / height;
  }

  static List<double> _normalizeImage(
      img.Image image, int x, int y, int width, int height, double mean) {
    return [
      for (var yy = 0; yy < height; yy++)
        for (var xx = 0; xx < width; xx++)
          image.getPixel(xx + x, yy + y).luminance - mean
    ];
  }

  static double _calculateNCC(img.Image window, int x, int y, int width,
      int height, List<double> template, double meanW) {
    double sumWt = 0, sumWw = 0.000001;
    var iT = template.iterator;
    for (var yy = y; yy < y + height; yy++) {
      for (var xx = x; xx < x + width; xx++) {
        iT.moveNext();
        var w = window.getPixel(xx, yy).luminance - meanW;
        sumWt += w * iT.current;
        sumWw += w * w;
      }
    }
    return sumWt / sumWw;
  }
}

class CaptchaWidget extends StatefulWidget {
  static double deviation = 5;

  final SliderCaptchaClientProvider provider;

  const CaptchaWidget({
    super.key,
    required this.provider,
  });

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  late Future<SliderCaptchaClientProvider> provider;

  /// 滑块的当前位置。
  double _sliderValue = 0.0;

  /// 滑到哪里了
  final _offsetValue = 0;

  @override
  void initState() {
    updateProvider();
    super.initState();
  }

  Future<void> updateProvider() async {
    _sliderValue = 0;
    provider = widget.provider.updatePuzzle().then((value) => widget.provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(
          context,
          "login.slider_title",
        )),
      ),
      body: FutureBuilder<SliderCaptchaClientProvider>(
        future: provider,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 堆叠三层，背景图、裁剪的拼图
                SizedBox(
                  width: snapshot.data!.puzzleWidth,
                  height: snapshot.data!.puzzleHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 背景图层
                      snapshot.data!.puzzleImage!.value,
                      // 拼图层
                      Positioned(
                        left: _sliderValue * snapshot.data!.puzzleWidth -
                            _offsetValue,
                        child: snapshot.data!.pieceImage!.value,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: snapshot.data!.puzzleWidth,
                  child: SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Colors.white, // 滑块颜色为白色
                      activeTrackColor: Colors.green[900], // 激活轨道颜色为深绿色
                      inactiveTrackColor: Colors.green[900], // 非激活轨道颜色为深绿色
                      trackHeight: 10.0, // 轨道高度
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10.0,
                      ), // 滑块形状为圆形
                    ),
                    child: Slider(
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                          //print(_sliderValue * snapshot.data!.puzzleWidth);
                        });
                      },
                      onChangeEnd: (value) async {
                        bool result = await snapshot.data!.verify(_sliderValue);
                        if (context.mounted) {
                          result
                              ? Navigator.of(context).pop()
                              : setState(() {
                                  updateProvider();
                                });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ).center();
          }
        },
      ),
    );
  }
}

class CaptchaSolveFailedException implements Exception {}
