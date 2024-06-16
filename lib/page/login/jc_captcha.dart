// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MIT

// http://thispage.tech:9680/jclee1995/flutter-jc-captcha/-/blob/master/lib/src/captcha_plugin_cn.dart
// https://juejin.cn/post/7284608063914622995

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/repository/network_session.dart';

class Lazy<T> {
  final T Function() _initializer;

  Lazy(this._initializer);

  T? _value;

  T get value => _value ??= _initializer();
}

class SliderCaptchaClientProvider {
  final String cookie;
  Dio dio = Dio()..interceptors.add(aliceDioAdapter);

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

  static double? _trySolve(Uint8List puzzleData, Uint8List pieceData) {
    img.Image? puzzle = img.decodeImage(puzzleData);
    if (puzzle == null) {
      return null;
    }

    img.Image? piece = img.decodeImage(pieceData);
    if (piece == null) {
      return null;
    }

    // note that puzzle and piece have the same height

    int minY = piece.height - 1;
    int maxY = 0;

    for (var y = 0; y < piece.height; y++) {
      if (piece.getPixel((piece.width * 0.5).floor(), y).a > 0) {
        minY = min(minY, y);
        maxY = max(maxY, y);
      }
    }

    for (var x = 1; x < puzzle.width - 1; x++) {
      int matchCount = 0;

      for (var y = minY; y <= maxY; y++) {
        var l = _getPixelGrayscale(puzzle.getPixel(x - 1, y));
        var r = _getPixelGrayscale(puzzle.getPixel(x + 1, y));

        // find edge
        if ((r - l).abs() > 50) {
          matchCount++;
        }
      }

      if ((matchCount / (maxY - minY + 1.0)) > 0.6) {
        return x / puzzle.width;
      }
    }

    return null;
  }

  static int _getPixelGrayscale(img.Pixel p) {
    return (0.2126 * p.r + 0.7152 * p.g + 0.0722 * p.b).round();
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
