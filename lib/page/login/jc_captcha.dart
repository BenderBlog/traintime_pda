// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MIT

// http://thispage.tech:9680/jclee1995/flutter-jc-captcha/-/blob/master/lib/src/captcha_plugin_cn.dart
// https://juejin.cn/post/7284608063914622995

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  Future<void> solve(BuildContext context, {int retryCount = 3}) async {
    for (int i = 0; i < retryCount; i++) {
      await updatePuzzle();

      double? answer = _trySolve(puzzleData!, pieceData!);
      if (answer != null && await verify(answer)) {
        return;
      }
    }

    // fallback
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CaptchaWidget(provider: this),
        ),
      );
    }
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
      {int border = 8}) {
    img.Image? puzzle = img.decodeImage(puzzleData);
    if (puzzle == null) {
      return null;
    }
    img.Image? piece = img.decodeImage(pieceData);
    if (piece == null) {
      return null;
    }

    var bbox = _findAlphaBoundingBox(piece);
    int xL = bbox[0] + border;
    int yT = bbox[1] + border;
    int xR = bbox[2] - border;
    int yB = bbox[3] - border;

    var widthW = xR - xL;
    var heightW = yB - yT;
    var widthG = puzzle.width - piece.width + widthW - 1;
    var gray = img.grayscale(puzzle);

    var template = img.grayscale(
        img.copyCrop(piece, x: xL, y: yT, width: widthW, height: heightW));
    var meanT = _calculateMean(template);
    var templateN = _normalizeImage(template, meanT);

    double nccMax = 0;
    int xMax = 0;

    for (int x = 0; x <= widthG - widthW; x += 2) {
      var window =
          img.copyCrop(gray, x: x, y: yT, width: widthW, height: heightW);
      var meanW = _calculateMean(window);
      var ncc = _calculateNCC(window, templateN, meanW);
      if (ncc > nccMax) {
        nccMax = ncc;
        xMax = x;
      }
    }

    return xMax.toDouble();
  }

  static List<int> _findAlphaBoundingBox(img.Image image) {
    int left = image.width, top = image.height, right = 0, bottom = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).a.round() != 255) continue;
        if (x < left) left = x;
        if (y < top) top = y;
        if (x > right) right = x;
        if (y > bottom) bottom = y;
      }
    }
    return [left, top, right, bottom];
  }

  static double _calculateMean(img.Image image) {
    double total = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        total += image.getPixel(x, y).luminance;
      }
    }
    return total / (image.width * image.height);
  }

  static List<double> _normalizeImage(img.Image image, double mean) {
    var normalized = List<double>.filled(image.width * image.height, 0);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        normalized.add(image.getPixel(x, y).luminance - mean);
      }
    }
    return normalized;
  }

  static double _calculateNCC(
      img.Image window, List<double> template, double meanW) {
    var sumWt = 0.0;
    var sumWw = 0.0;
    for (int y = 0; y < window.height; y++) {
      for (int x = 0; x < window.width; x++) {
        var w = window.getPixel(x, y).luminance - meanW;
        var t = template[y * window.width + x];
        sumWt += w * t;
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
        title: const Text("服务器认证服务"),
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
