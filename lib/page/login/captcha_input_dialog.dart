// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// A captcha input dialog.

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CaptchaInputDialog extends StatelessWidget {
  final TextEditingController _captchaController = TextEditingController();
  final String cookie;

  CaptchaInputDialog({super.key, required this.cookie});

  @override
  Widget build(BuildContext context) {
    NetworkImage cappic = NetworkImage(
      "https://ids.xidian.edu.cn/authserver/getCaptcha.htl",
      headers: {"Cookie": cookie},
    );

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
          Image(image: cappic),
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
              Fluttertoast.showToast(msg: '请输入验证码');
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
