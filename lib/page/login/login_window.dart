// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Login window of the program.

import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/login/app_icon.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/homepage/home.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/login/bottom_buttons.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({super.key});

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  /// The rest of Text Editing Controller
  final TextEditingController _idsAccountController = TextEditingController();
  final TextEditingController _idsPasswordController = TextEditingController();

  /// Something related to the box.
  final double widthOfSquare = 32.0;
  final double roundRadius = 36;

  /// Variables of the input textfield
  final Color _inputFieldBackgroundColor =
      const Color.fromRGBO(250, 250, 250, 1);
  final Color _inputFieldColor = const Color.fromRGBO(35, 62, 99, 0.35);
  final double _inputFieldIconSize = 28;
  final double _inputFieldFontSize = 20;
  InputDecoration _inputDecoration({
    required IconData iconData,
    required String hintText,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(
          iconData,
          size: _inputFieldIconSize,
          color: _inputFieldColor,
        ),
        hintStyle: TextStyle(
          fontSize: _inputFieldFontSize,
          color: _inputFieldColor,
        ),
        hintText: hintText,
        suffixIcon: suffixIcon,
      );

  /// Can I see the password?
  bool _couldNotView = true;

  Widget contentColumn() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _idsAccountController,
            decoration: _inputDecoration(
              iconData: MingCuteIcons.mgc_user_3_fill,
              hintText: "学号",
            ),
          ).center().padding(horizontal: 12).decorated(
            color: _inputFieldBackgroundColor,
            borderRadius: BorderRadius.circular(roundRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(19),
                offset: const Offset(0, 2),
                blurRadius: 1,
              ),
            ],
          ).height(64),
          const SizedBox(height: 16.0),
          TextField(
            controller: _idsPasswordController,
            obscureText: _couldNotView,
            decoration: _inputDecoration(
              iconData: MingCuteIcons.mgc_safe_lock_fill,
              hintText: "一站式登录密码",
              suffixIcon: IconButton(
                icon: Icon(
                  _couldNotView ? Icons.visibility : Icons.visibility_off,
                  size: _inputFieldIconSize,
                  color: _inputFieldColor,
                ),
                onPressed: () {
                  setState(() {
                    _couldNotView = !_couldNotView;
                  });
                },
              ),
            ),
          ).center().padding(horizontal: 12).decorated(
            color: _inputFieldBackgroundColor,
            borderRadius: BorderRadius.circular(roundRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(19),
                offset: const Offset(0, 2),
                blurRadius: 1,
              ),
            ],
          ).height(64),
          SizedBox(height: width / height > 1.0 ? 16.0 : 64.0),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.all(12.0),
              minimumSize: const Size(double.infinity, 56),
              maximumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(roundRadius),
              ),
            ),
            child: const Text(
              "登录",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            onPressed: () async {
              if (_idsAccountController.text.length == 11 &&
                  _idsPasswordController.text.isNotEmpty) {
                await login();
              } else {
                Fluttertoast.showToast(msg: '用户名或密码不符合要求，学号必须 11 位且密码非空');
              }
            },
          ),
          const SizedBox(height: 8.0),
          const ButtomButtons(),
        ],
      ).constrained(maxWidth: 400);

  Future<void> login() async {
    bool isGood = true;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: '正在登录学校一站式',
      max: 100,
      hideValue: true,
      completed: Completed(completedMsg: "登录成功"),
    );
    EhallSession ses = EhallSession();

    try {
      await ses.clearCookieJar();
      log.w(
        "[login_window][login] "
        "Have cleared login state.",
      );
    } on Exception {
      log.w(
        "[login_window][login] "
        "No clear state.",
      );
    }

    try {
      await ses.loginEhall(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
        onResponse: (int number, String status) =>
            pd.update(msg: status, value: number),
        sliderCaptcha: (String cookieStr) {
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CaptchaWidget(cookie: cookieStr),
            ),
          );
        },
      );
      if (!mounted) return;
      if (isGood == true) {
        preference.setString(
          preference.Preference.idsAccount,
          _idsAccountController.text,
        );
        preference.setString(
          preference.Preference.idsPassword,
          _idsPasswordController.text,
        );
        await ses.getInformation();
        if (mounted) {
          if (pd.isOpen()) pd.close();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } catch (e, s) {
      isGood = false;
      pd.close();
      if (mounted) {
        if (e is PasswordWrongException) {
          Fluttertoast.showToast(msg: e.msg);
        } else if (e is LoginFailedException) {
          Fluttertoast.showToast(msg: e.msg);
        } else if (e is DioException) {
          if (e.message == null) {
            if (e.response == null) {
              Fluttertoast.showToast(msg: "无法连接到服务器。");
            } else {
              Fluttertoast.showToast(
                  msg: "请求失败，响应状态码：${e.response!.statusCode}。");
            }
          } else {
            Fluttertoast.showToast(msg: "请求失败。${e.message}");
          }
        } else {
          log.w(
            "[login_window][login] "
            "Login failed with error: \n$e\nStacktrace is:\n$s",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().substring(
                      0,
                      min(
                        e.toString().length,
                        120,
                      ),
                    ),
              ),
            ),
          );
          Fluttertoast.showToast(
            msg: "未知错误，请联系开发者。",
          );
        }
      }
    }
  }

  double get width => MediaQuery.sizeOf(context).width;
  double get height => MediaQuery.sizeOf(context).height;

  @override
  void initState() {
    super.initState();

    var cachedAccount = preference.getString(preference.Preference.idsAccount);
    if (cachedAccount.isNotEmpty) {
      _idsAccountController.text = cachedAccount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: width / height > 1.0 ? width * 0.2 : widthOfSquare,
          right: width / height > 1.0 ? width * 0.2 : widthOfSquare,
          top: kToolbarHeight,
        ),
        child: width / height > 1.0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIconWidget(),
                  const SizedBox(
                    width: 48,
                  ),
                  Expanded(
                    child: contentColumn(),
                  ),
                ],
              )
            : Column(
                children: [
                  const AppIconWidget().padding(
                    vertical: kToolbarHeight * 0.75,
                  ),
                  contentColumn(),
                ],
              ).center(),
      ),
    );
  }
}
