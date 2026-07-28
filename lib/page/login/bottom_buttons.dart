// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/generated/translations.g.dart';

class ButtomButtons extends StatelessWidget {
  /// Variables of the three buttons in the bottom
  final Color _bottomTextColor = const Color.fromRGBO(35, 62, 99, 0.5);
  TextStyle get _bottomTextStyle =>
      TextStyle(color: _bottomTextColor, fontWeight: FontWeight.w700);

  const ButtomButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          child: Text(
            context.t.login.clearCache,
            style: _bottomTextStyle,
          ),
          onPressed: () {
            NetworkSession().clearCookieJar().then((value) {
              if (context.mounted) {
                showToast(
                  context: context,
                  msg: context.t.login.completeClearCache,
                );
              }
            });
          },
        ),
        TextButton(
          child: Text(
            context.t.login.seeInspector,
            style: _bottomTextStyle,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TalkerScreen(talker: log),
              ),
            );
          },
        ),
      ],
    );
  }
}
