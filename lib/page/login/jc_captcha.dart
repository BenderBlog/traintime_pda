// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MIT

// http://thispage.tech:9680/jclee1995/flutter-jc-captcha/-/blob/master/lib/src/captcha_plugin_cn.dart
// https://juejin.cn/post/7284608063914622995

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/repository/network_session.dart';

class SliderCaptchaClientProvider {
  ///Data of the image after decode base64
  late Uint8List puzzleUnit8List;

  ///Data of the piece after decode base64
  late Uint8List pieceUnit8List;

  /// Actual size of the image
  late Size puzzleSize;

  ///Actual size of the piece
  late Size pieceSize;

  ///Image is cut 1 piece
  Image? puzzleImage;

  ///piece is cut from Image
  Image? pieceImage;

  ///The ratio of the image to the actual size of the screen.
  late double ratio;

  ///Init piece base64 type
  final String puzzleBase64;

  /// Init piece base64 type:
  final String pieceBase64;

  ///Y coordinate of the puzzle piece.
  final double coordinatesY;

  late double puzzleWidth = 280;

  late double pieceWidth = 44;

  late double puzzleHeight = 155;

  late double pieceHeight = 155;

  /// Provides Image information from the original base64 data
  SliderCaptchaClientProvider(
      this.puzzleBase64, this.pieceBase64, this.coordinatesY) {
    puzzleUnit8List = const Base64Decoder().convert(puzzleBase64);
    pieceUnit8List = const Base64Decoder().convert(pieceBase64);
  }

  ///This is the required function to be executed to initialize the values.
  Future<bool> init() async {
    puzzleSize = await _getSize(puzzleUnit8List);
    pieceSize = await _getSize(pieceUnit8List);
    puzzleImage = Image.memory(
      puzzleUnit8List,
      height: puzzleHeight,
      width: puzzleWidth,
      fit: BoxFit.fitWidth,
    );
    pieceImage = Image.memory(
      pieceUnit8List,
      width: pieceWidth,
      height: pieceHeight,
      fit: BoxFit.fitWidth,
    );
    return true;
  }

  /// Actual size of the image in pixels
  Future<Size> _getSize(Uint8List puzzleUnit8List) async {
    var image = await decodeImageFromList(puzzleUnit8List);
    return Size(image.width.toDouble(), image.height.toDouble());
  }
}

class CaptchaWidget extends StatefulWidget {
  final String cookie;

  static double deviation = 5;

  const CaptchaWidget({
    Key? key,
    required this.cookie,
  }) : super(key: key);

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

  Dio dio = Dio()..interceptors.add(alice.getDioInterceptor());

  Future<void> updateProvider() async {
    _sliderValue = 0;
    provider = dio
        .get(
      "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
      options: Options(headers: {"Cookie": widget.cookie}),
    )
        .then(
      (value) async {
        var provider = SliderCaptchaClientProvider(
          value.data["bigImage"],
          value.data["smallImage"],
          double.parse(value.data["tagWidth"].toString()),
        );
        await provider.init();
        return provider;
      },
    );
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
                      snapshot.data!.puzzleImage!,
                      // 拼图层
                      Positioned(
                        left: _sliderValue * snapshot.data!.puzzleWidth -
                            _offsetValue,
                        child: snapshot.data!.pieceImage!,
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
                        /// Can you verify captcha at here
                        bool result = await dio
                            .post(
                          "https://ids.xidian.edu.cn/authserver/common/verifySliderCaptcha.htl",
                          data: "canvasLength=${(snapshot.data!.puzzleWidth)}&"
                              "moveLength=${(_sliderValue * snapshot.data!.puzzleWidth).toInt()}",
                          options: Options(
                            headers: {
                              "Cookie": widget.cookie,
                              HttpHeaders.contentTypeHeader:
                                  "application/x-www-form-urlencoded;charset=utf-8",
                              HttpHeaders.accessControlAllowOriginHeader:
                                  "https://ids.xidian.edu.cn",
                            },
                          ),
                        )
                            .then((value) {
                          //print((_sliderValue * snapshot.data!.puzzleWidth).toInt().toString());
                          //print(value.data.toString());
                          return value.data["errorCode"] == 1;
                        });
                        if (mounted) {
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
