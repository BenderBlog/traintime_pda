// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Login window of the program.

import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/setting/about_page/about_page.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/ids_session/slider_captcha_client.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/homepage/home.dart';
import 'package:watermeter/repository/ids_session/ids_session.dart';
import 'package:watermeter/page/login/bottom_buttons.dart';
import 'package:watermeter/page/login/ids_reauth_dialog.dart';
import 'package:watermeter/repository/ids_session/semester_session.dart';
import 'package:watermeter/repository/ids_session/ids_auth_protocol.dart';
import 'package:watermeter/repository/ids_session/ids_reauth_client.dart';
import 'package:watermeter/generated/translations.g.dart';

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
          hintText: context.t.login.identityNumber,
        ),
      ).center(),
      const SizedBox(height: 16.0),
      TextField(
        controller: _idsPasswordController,
        obscureText: _couldNotView,
        decoration: _inputDecoration(
          iconData: MingCuteIcons.mgc_safe_lock_fill,
          hintText: context.t.login.password,
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
          context.t.login.login,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        onPressed: () async {
          if (_idsPasswordController.text.isNotEmpty) {
            await login();
          } else {
            showToast(
              context: context,
              msg: context.t.login.incorrectPasswordPattern,
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
    loginState = IDSLoginState.requesting;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: context.t.login.onLoginProgress,
      max: 100,
      hideValue: true,
      completed: Completed(
        completedMsg: context.t.login.completeLogin,
      ),
    );
    IDSSession ses = IDSSession();

    try {
      await NetworkCookieJars.ids.deleteAll();
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
      Future<Uri> reAuthHandler(IDSReAuthClient client) async {
        if (pd.isOpen()) pd.close();
        if (!mounted) throw const IDSReAuthCancelledException();
        final result = await showIDSReAuthDialog(context, client);
        if (mounted && !pd.isOpen()) {
          pd.show(
            msg: context.t.loginProcess.afterProcess,
            max: 100,
            hideValue: true,
          );
        }
        return result;
      }

      await ses.login(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
        onResponse: (int number, LoginProcessStep status) {
          if (pd.isOpen()) {
            pd.update(
              msg: switch (status) {
                LoginProcessStep.readyPage =>
                  context.t.loginProcess.readyPage,
                LoginProcessStep.getEncrypt =>
                  context.t.loginProcess.getEncrypt,
                LoginProcessStep.readyLogin =>
                  context.t.loginProcess.readyLogin,
                LoginProcessStep.slider =>
                  context.t.loginProcess.slider,
                LoginProcessStep.secondFactor =>
                  context.t.loginProcess.secondFactor,
                LoginProcessStep.afterProcess =>
                  context.t.loginProcess.afterProcess,
              },
              value: number,
            );
          }
        },
        reAuthHandler: (IDSReAuthClient client) async {
          if (pd.isOpen()) pd.close();
          if (!mounted) throw const IDSReAuthCancelledException();
          final result = await showIDSReAuthDialog(context, client);
          if (mounted && !pd.isOpen()) {
            pd.show(
              msg: context.t.loginProcess.afterProcess,
              max: 100,
              hideValue: true,
            );
          }
          return result;
        },
        sliderCaptcha: (String cookieStr) {
          return SliderCaptchaClientProvider(cookie: cookieStr).solve(
            manualSolver: (provider) =>
                solveSliderCaptchaManually(context, provider),
          );
        },
      );
      if (!mounted) return;
      if (isGood == true) {
        loginState = IDSLoginState.success;
        await preference.setString(
          preference.Preference.idsAccount,
          _idsAccountController.text,
        );
        await preference.setString(
          preference.Preference.idsPassword,
          _idsPasswordController.text,
        );

        bool isPostGraduate = await ses.checkWhetherPostgraduate(
          reAuthHandler: reAuthHandler,
        );
        String semesterInfo = isPostGraduate
            ? await SemesterSession().getSemesterInfoYjspt()
            : await SemesterSession().getSemesterInfoEhall();
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
      if (pd.isOpen()) pd.close();
      if (mounted) {
        if (e is PasswordWrongException) {
          loginState = IDSLoginState.passwordWrong;
          showToast(context: context, msg: e.msg);
        } else if (e is IDSReAuthCancelledException) {
          loginState = IDSLoginState.cancelled;
          showToast(
            context: context,
            msg: context.t.login.secondFactor.cancelled,
          );
        } else if (e is IDSReAuthExpiredException) {
          loginState = IDSLoginState.fail;
          showToast(
            context: context,
            msg: context.t.login.secondFactor.expired,
          );
        } else if (e is LoginFailedException) {
          loginState = IDSLoginState.fail;
          showToast(context: context, msg: e.msg);
        } else if (e is IDSProtocolException) {
          loginState = IDSLoginState.fail;
          showToast(context: context, msg: e.message);
        } else if (e is DioException) {
          loginState = IDSLoginState.fail;
          if (e.message == null) {
            if (e.response == null) {
              showToast(
                context: context,
                msg: context.t.login.failedLoginCannotConnectToServer,
              );
            } else {
              showToast(
                context: context,
                msg: context.t.login.failedLoginWithCode(code: e.response!.statusCode.toString()),
              );
            }
          } else {
            showToast(
              context: context,
              msg: context.t.login.failedLoginWithMessage(message: e.message.toString()),
            );
          }
        } else {
          loginState = IDSLoginState.fail;
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
            msg: context.t.login.failedLoginOther,
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
      resizeToAvoidBottomInset: false,
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
