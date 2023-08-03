/*
Login window of the watermeter program.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:watermeter/page/xdu_planet/xdu_planet_page.dart';
import 'package:watermeter/repository/xidian_ids/ehall/ehall_session.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/page/login/captcha_input_dialog.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({Key? key}) : super(key: key);

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  /// The rest of Text Editing Controller
  final TextEditingController _idsAccountController = TextEditingController();
  final TextEditingController _idsPasswordController = TextEditingController();

  /// Can I see the password?
  bool _couldNotView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Temporary symbol of watermeter.
          const CircleAvatar(
            backgroundImage: AssetImage("assets/icon.png"),
            radius: 60.0,
          ),
          const SizedBox(height: 15.0),
          const Text('请登录 Traintime PDA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              )),
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: widthOfSquare),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(roundRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextField(
                  autofocus: true,
                  controller: _idsAccountController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: "学号",
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: widthOfSquare),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(roundRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextField(
                  controller: _idsPasswordController,
                  obscureText: _couldNotView,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: "一站式登录密码",
                    suffixIcon: IconButton(
                        icon: Icon(_couldNotView
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _couldNotView = !_couldNotView;
                          });
                        }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: widthOfSquare),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA267AC),
                padding: const EdgeInsets.all(20.0),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(roundRadius)),
              ),
              child: const Text(
                "登录",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              onPressed: () async {
                if (_idsAccountController.text.length == 11 &&
                    _idsPasswordController.text.isNotEmpty) {
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
                    await ses.login(
                      username: _idsAccountController.text,
                      password: _idsPasswordController.text,
                      onResponse: (int number, String status) =>
                          pd.update(msg: status, value: number),
                      getCaptcha: (String cookieStr) {
                        return showDialog<String>(
                            context: context,
                            builder: (context) =>
                                CaptchaInputDialog(cookie: cookieStr));
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
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                      }
                    }
                  } catch (e) {
                    isGood = false;
                    pd.close();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('用户名或密码不符合要求，学号必须 11 位且密码非空'),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text(
                  '清除登录缓存',
                  style: TextStyle(
                    color: Color(0xFFA267AC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  NetworkSession().clearCookieJar().then(
                        (value) => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('清理缓存成功'),
                          ),
                        ),
                      );
                },
              ),
              TextButton(
                child: const Text(
                  '查看网络交互',
                  style: TextStyle(
                    color: Color(0xFFA267AC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  alice.showInspector();
                },
              ),
              TextButton(
                child: const Text(
                  'XDU Planet',
                  style: TextStyle(
                    color: Color(0xFFA267AC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const XDUPlanetPage(),
                )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
