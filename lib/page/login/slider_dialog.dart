// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
/*
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:slider_captcha/slider_captcha.dart';

class SliderDialog extends StatefulWidget {
  final String cookie;
  const SliderDialog({super.key, required this.cookie});

  @override
  State<SliderDialog> createState() => _SliderDialogState();
}

class _SliderDialogState extends State<SliderDialog> {
  late Future<SliderCaptchaClientProvider> provider;

  @override
  void initState() {
    updateProvider();
    super.initState();
  }

  void updateProvider() {
    Dio dio = Dio();
    provider = dio
        .get(
          "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl?_=1701775739201",
          queryParameters: {
            '_': DateTime.now().millisecondsSinceEpoch.toString()
          },
          options: Options(headers: {"Cookie": widget.cookie}),
        )
        .then(
          (value) => SliderCaptchaClientProvider(
            value.data["bigImage"],
            value.data["smallImage"],
            double.parse(value.data["tagWidth"].toString()),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('请输入验证码')),
      body: FutureBuilder(
        future: provider,
        builder: (context, snapshot) => snapshot.hasData
            ? SliderCaptchaClient(
                provider: snapshot.data!,
                onConfirm: (value) async {
                  /// Can you verify captcha at here
                  Dio dio = Dio();
                  bool result = await dio
                      .post(
                        "https://ids.xidian.edu.cn/authserver/common/verifySliderCaptcha.htl",
                        data: "canvasLength=280&moveLength=${value.toInt()}",
                        options: Options(headers: {"Cookie": widget.cookie}),
                      )
                      .then(
                        (value) => value.data["errorCode"] == 1,
                      );
                  if (mounted) {
                    result ? Navigator.of(context).pop() : updateProvider();
                  }
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
*/