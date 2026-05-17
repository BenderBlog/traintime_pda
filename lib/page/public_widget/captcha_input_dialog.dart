// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// A captcha input dialog.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class CaptchaInputDialog extends StatelessWidget {
  final TextEditingController _captchaController = TextEditingController();
  final List<int> image;

  CaptchaInputDialog({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "login.captcha_window.title")),
      titleTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
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
          child: Text(FlutterI18n.translate(context, "cancel")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(context, "confirm")),
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
