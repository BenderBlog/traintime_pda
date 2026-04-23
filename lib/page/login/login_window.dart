// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Login window of the program.

import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/setting/about_page/about_page.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/homepage/home.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/page/login/bottom_buttons.dart';
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';

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
  InputDecoration _inputDecoration({
    required IconData iconData,
    required String hintText,
    Widget? suffixIcon,
  }) => InputDecoration(
    prefixIcon: Icon(iconData),
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
          hintText: FlutterI18n.translate(context, "login.identity_number"),
        ),
      ).center(),
      const SizedBox(height: 16.0),
      TextField(
        controller: _idsPasswordController,
        obscureText: _couldNotView,
        decoration: _inputDecoration(
          iconData: MingCuteIcons.mgc_safe_lock_fill,
          hintText: FlutterI18n.translate(context, "login.password"),
          suffixIcon: IconButton(
            icon: Icon(_couldNotView ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _couldNotView = !_couldNotView;
              });
            },
          ),
        ),
      ).center(),
      SizedBox(height: width / height > 1.0 ? 16.0 : 64.0),
      FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          maximumSize: const Size(double.infinity, 64),
        ),
        child: Text(
          FlutterI18n.translate(context, "login.login"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        onPressed: () async {
          if (_idsPasswordController.text.isNotEmpty) {
            await login();
          } else {
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                "login.incorrect_password_pattern",
              ),
            );
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
      msg: FlutterI18n.translate(context, "login.on_login_progress"),
      max: 100,
      hideValue: true,
      completed: Completed(
        completedMsg: FlutterI18n.translate(context, "login.complete_login"),
      ),
    );
    EhallSession ses = EhallSession();

    try {
      await ses.clearCookieJar();
      log.warning(
        "[login_window][login] "
        "Have cleared login state.",
      );
    } on Exception {
      log.warning(
        "[login_window][login] "
        "No clear state.",
      );
    }

    try {
      await ses.loginEhall(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
        onResponse: (int number, String status) => pd.update(
          msg: FlutterI18n.translate(context, status),
          value: number,
        ),
        sliderCaptcha: (String cookieStr) {
          return SliderCaptchaClientProvider(cookie: cookieStr).solve(context);
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

        bool isPostGraduate = await ses.checkWhetherPostgraduate();
        String semesterInfo = isPostGraduate
            ? await PersonalInfoSession().getSemesterInfoYjspt()
            : await PersonalInfoSession().getSemesterInfoEhall();
        preference.setString(
          preference.Preference.currentSemester,
          semesterInfo,
        );
        preference.setBool(preference.Preference.isUserDefinedSemester, false);

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
          showToast(context: context, msg: e.msg);
        } else if (e is LoginFailedException) {
          showToast(context: context, msg: e.msg);
        } else if (e is DioException) {
          if (e.message == null) {
            if (e.response == null) {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "login.failed_login_cannot_connect_to_server",
                ),
              );
            } else {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "login.failed_login_with_code",
                  translationParams: {
                    "code": e.response!.statusCode.toString(),
                  },
                ),
              );
            }
          } else {
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                "login.failed_login_with_message",
                translationParams: {"message": e.message.toString()},
              ),
            );
          }
        } else {
          log.warning(
            "[login_window][login] "
            "Login failed with error: \n$e\nStacktrace is:\n$s",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().substring(0, min(e.toString().length, 120)),
              ),
            ),
          );
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "login.failed_login_other"),
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
          left: width / height > 1.0 ? width * 0.25 : widthOfSquare,
          right: width / height > 1.0 ? width * 0.25 : widthOfSquare,
          top: kToolbarHeight,
        ),
        child: width / height > 1.0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIconWidget().gestures(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(child: contentColumn()),
                ],
              )
            : Column(
                children: [
                  const AppIconWidget()
                      .padding(vertical: kToolbarHeight * 0.75)
                      .gestures(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                          ),
                        ),
                      ),
                  contentColumn(),
                ],
              ).center(),
      ),
    );
  }
}
