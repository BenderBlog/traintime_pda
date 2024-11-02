// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Electricity account dialog.

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ElectricityAccountDialog extends StatelessWidget {
  final TextEditingController _controller =
      TextEditingController.fromValue(TextEditingValue(
    text: preference.getString(preference.Preference.dorm),
    selection: TextSelection.fromPosition(TextPosition(
      affinity: TextAffinity.downstream,
      offset: preference.getString(preference.Preference.dorm).length,
    )),
  ));

  ElectricityAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改电费账户密码'),
      content: TextField(
        autofocus: true,
        controller: _controller,
        decoration: const InputDecoration(
          hintText: "请在此输入账号",
          border: OutlineInputBorder(),
        ),
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
            if (_controller.text.isNotEmpty) {
              preference.setString(
                preference.Preference.dorm,
                _controller.text,
              );
              Navigator.of(context).pop();
            } else {
              showToast(context: context, msg: "输入空白!");
            }
          },
        ),
      ],
    );
  }
}
