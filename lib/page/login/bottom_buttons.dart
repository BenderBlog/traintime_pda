// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';

class ButtomButtons extends StatelessWidget {
  /// Variables of the three buttons in the bottom
  final Color _bottomTextColor = const Color.fromRGBO(35, 62, 99, 0.5);
  TextStyle get _bottomTextStyle => TextStyle(
        color: _bottomTextColor,
        fontWeight: FontWeight.w700,
      );

  const ButtomButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          child: Text('清除登录缓存', style: _bottomTextStyle),
          onPressed: () {
            NetworkSession().clearCookieJar().then((value) {
              if (context.mounted) showToast(context: context, msg: '清理缓存成功');
            });
          },
        ),
        TextButton(
          child: Text('查看网络交互', style: _bottomTextStyle),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TalkerScreen(talker: log),
            ));
          },
        ),
      ],
    );
  }
}
