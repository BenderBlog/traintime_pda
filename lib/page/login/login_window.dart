// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Login window of the program.

import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/login/app_icon.dart';
import 'package:watermeter/repository/xidian_ids/ehall/ehall_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/login/captcha_input_dialog.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/login/bottom_buttons.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({Key? key}) : super(key: key);

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
      );

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
      developer.log("已经清除上次登录状态", name: "Login");
    } on Exception {
      developer.log("没有登录状态", name: "Login");
    }

    try {
      await ses.login(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
        onResponse: (int number, String status) =>
            pd.update(msg: status, value: number),
        getCaptcha: (String cookieStr) {
          return showDialog<String>(
            context: context,
            builder: (context) => CaptchaInputDialog(cookie: cookieStr),
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
    } catch (e) {
      isGood = false;
      pd.close();
      if (mounted) {
        if (e is PasswordWrongException) {
          Fluttertoast.showToast(msg: "输入账号或密码错误");
        } else {
          developer.log("Login failed: $e", name: "Login");
          Fluttertoast.showToast(
            msg: "登录遇到错误，请清除登录缓存。\n${e.toString().substring(20)}",
          );
        }
      }
    }
  }

  double get width => MediaQuery.sizeOf(context).width;
  double get height => MediaQuery.sizeOf(context).height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: isPhone(context) ? widthOfSquare : width * 0.2,
          right: isPhone(context) ? widthOfSquare : width * 0.2,
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
              ),
      ),
    );
  }
}
