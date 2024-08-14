// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// A captcha input dialog.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class CaptchaInputDialog extends StatelessWidget {
  final TextEditingController _captchaController = TextEditingController();
  final Uint8List image;

  CaptchaInputDialog({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('请输入验证码'),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.memory(image),
          TextField(
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            controller: _captchaController,
            decoration: InputDecoration(
              hintText: "输入验证码",
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
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('提交'),
          onPressed: () async {
            if (_captchaController.text.isEmpty) {
              showToast(context: context, msg: '请输入验证码');
            } else {
              Navigator.of(context).pop<String>(_captchaController.text);
            }
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
