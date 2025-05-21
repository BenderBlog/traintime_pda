// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// A captcha input dialog.

import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum DigitCaptchaType { payment, zfw }

class DigitCaptchaClientProvider {
  // Ref: https://github.com/stalomeow/captcha-solver

  static String _getInterpreterAssetName(DigitCaptchaType type) {
    return 'assets/captcha-solver-${type.name.toLowerCase()}.tflite';
  }

  static double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static num _sampleMin(img.Image image, List<int> bb, double u, double v) {
    int x = _lerp(bb[0] * 1.0, bb[2] - 1.0, u).floor();
    int y = _lerp(bb[1] * 1.0, bb[3] - 1.0, v).floor();
    num px = min(image.getPixelClamped(x, y + 0).r,
        image.getPixelClamped(x + 1, y + 0).r);
    num py = min(image.getPixelClamped(x, y + 1).r,
        image.getPixelClamped(x + 1, y + 1).r);
    return min(px, py);
  }

  static List<int> _getbbox(img.Image image) {
    int left = image.width;
    int upper = image.height;
    int right = 0; // Exclusive
    int lower = 0; // Exclusive

    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        num p = image.getPixel(x, y).r;

        // Binarization
        if (p < 0.98) {
          continue;
        }

        left = min(left, x);
        upper = min(upper, y);
        right = max(right, x + 1);
        lower = max(lower, y + 1);
      }
    }

    // Expand the bounding box by 1 pixel
    left = max(0, left - 1);
    upper = max(0, upper - 1);
    right = min(image.width, right + 1);
    lower = min(image.height, lower + 1);

    return [left, upper, right, lower];
  }

  static img.Image? _getImage(DigitCaptchaType type, List<int> imageData) {
    img.Image image = img.decodeImage(Uint8List.fromList(imageData))!;
    image = img.grayscale(image);
    image = image.convert(
        format: img.Format.float32, numChannels: 1); // 0-256 to 0-1

    if (type == DigitCaptchaType.zfw) {
      // Invert the image
      for (int x = 0; x < image.width; x++) {
        for (int y = 0; y < image.height; y++) {
          image.setPixelR(x, y, 1.0 - image.getPixel(x, y).r);
        }
      }

      List<int> bb = _getbbox(image);

      // The numbers are too close
      if (bb[2] - bb[0] < 44) {
        return null;
      }

      // Align with the size of payment captcha
      img.Image result = img.Image(
          width: 200, height: 80, format: img.Format.float32, numChannels: 1);
      for (int x = 0; x < result.width; x++) {
        for (int y = 0; y < result.height; y++) {
          double u = x * 1.0 / result.width;
          double v = y * 1.0 / result.height;
          num r = _sampleMin(image, bb, u, v);
          result.setPixelR(x, y, r);
        }
      }
      image = result;
    }

    return image;
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

  static int _getClassCount(DigitCaptchaType type) {
    if (type == DigitCaptchaType.payment) {
      return 9; // The payment captcha only contains number 1-9
    }
    return 10;
  }

  static int _getClassLabel(DigitCaptchaType type, int klass) {
    if (type == DigitCaptchaType.payment) {
      return klass + 1; // The payment captcha only contains number 1-9
    }
    return klass;
  }

  static Future<String?> infer(
      DigitCaptchaType type, List<int> imageData) async {
    img.Image? image = _getImage(type, imageData);

    if (image == null) {
      return null;
    }

    int dim2 = image.height;
    int dim3 = image.width ~/ 4;
    int classCount = _getClassCount(type);

    var input = List.filled(dim2 * dim3, 0.0)
        .reshape<double>([1, dim2, dim3, 1]) as List<List<List<List<double>>>>;
    var output = List.filled(classCount, 0.0).reshape<double>([1, classCount])
        as List<List<double>>;

    final interpreter =
        await Interpreter.fromAsset(_getInterpreterAssetName(type));
    List<int> nums = [];

    // Four numbers
    for (int i = 0; i < 4; i++) {
      for (int y = 0; y < dim2; y++) {
        for (int x = 0; x < dim3; x++) {
          input[0][y][x][0] = image.getPixel(x + dim3 * i, y).r.toDouble();
        }
      }

      interpreter.run(input, output);
      nums.add(_getClassLabel(type, _argmax(output[0])));
    }

    return nums.join('');
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
