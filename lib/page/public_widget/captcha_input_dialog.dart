// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// A captcha input dialog.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class DigitCaptchaClientProvider {
  static const String _interpreterAssetName = 'assets/captcha-solver.tflite';

  static Future<String> infer(List<int> imageData) async {
    img.Image image = img.decodeImage(Uint8List.fromList(imageData))!;
    image = img.grayscale(image);
    image = image.convert(
        format: img.Format.float32, numChannels: 1); // 0-256 to 0-1

    int dim2 = image.height;
    int dim3 = image.width ~/ 4;

    var input = List.filled(dim2 * dim3, 0.0)
        .reshape<double>([1, dim2, dim3, 1]) as List<List<List<List<double>>>>;
    var output =
        List.filled(9, 0.0).reshape<double>([1, 9]) as List<List<double>>;

    final interpreter = await Interpreter.fromAsset(_interpreterAssetName);
    List<int> nums = [];

    // Four numbers
    for (int i = 0; i < 4; i++) {
      for (int y = 0; y < dim2; y++) {
        for (int x = 0; x < dim3; x++) {
          input[0][y][x][0] = image.getPixel(x + dim3 * i, y).r.toDouble();
        }
      }

      interpreter.run(input, output);
      nums.add(_argmax(output[0]) + 1);
    }

    return nums.join('');
  }

  static int _argmax(List<double> list) {
    int result = 0;
    for (int i = 1; i < list.length; i++) {
      if (list[i] > list[result]) {
        result = i;
      }
    }
    return result;
  }
}

class CaptchaInputDialog extends StatelessWidget {
  final TextEditingController _captchaController = TextEditingController();
  final List<int> image;

  CaptchaInputDialog({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(
        context,
        "login.captcha_window.title",
      )),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.memory(Uint8List.fromList(image)),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            controller: _captchaController,
            decoration: InputDecoration(
              hintText: FlutterI18n.translate(
                context,
                "login.captcha_window.hint",
              ),
              fillColor: Colors.grey.withOpacity(0.4),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "cancel",
          )),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "confirm",
          )),
          onPressed: () async {
            if (_captchaController.text.isEmpty) {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "login.captcha_window.message_on_empty",
                ),
              );
            } else {
              Navigator.of(context).pop(_captchaController.text);
            }
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
