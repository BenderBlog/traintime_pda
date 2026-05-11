// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MIT

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/repository/logger.dart';

class SliderCaptchaClientProvider {
  final String cookie;
  Dio dio = Dio()..interceptors.add(logDioAdapter);

  static String lastResult = '';

  SliderCaptchaClientProvider({required this.cookie});

  Uint8List? captchaData;

  Future<void> updatePuzzle() async {
    var rsp = await dio.get(
      "https://ids.xidian.edu.cn/authserver/getCaptcha.htl"
      "?${DateTime.now().millisecondsSinceEpoch}",
      options: Options(
        headers: {"Cookie": cookie},
        responseType: ResponseType.bytes,
      ),
    );

    captchaData = rsp.data as Uint8List;
  }

  Future<void> solve(BuildContext? context) async {
    await updatePuzzle();

    if (context != null && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CaptchaWidget(provider: this)),
      );
    } else {
      throw CaptchaSolveFailedException();
    }
  }
}

class CaptchaWidget extends StatefulWidget {
  final SliderCaptchaClientProvider provider;

  const CaptchaWidget({super.key, required this.provider});

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _refresh() async {
    await widget.provider.updatePuzzle();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "login.captcha_window.title"),
        ),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.provider.captchaData != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      widget.provider.captchaData!,
                      width: 280,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, letterSpacing: 6),
                        decoration: InputDecoration(
                          hintText: FlutterI18n.translate(
                            context,
                            "login.captcha_window.hint",
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refresh,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        SliderCaptchaClientProvider.lastResult =
                            _controller.text;
                        Navigator.of(context).pop();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        FlutterI18n.translate(context, "confirm"),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CaptchaSolveFailedException implements Exception {}
