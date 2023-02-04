/*
Login window of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

// Color card: https://colorhunt.co/palette/be9fe1c9b6e4e1ccecf1f1f6

import 'package:flutter/material.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';
import 'package:watermeter/repository/general.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/modified_library/sprt_sn_progress_dialog/sprt_sn_progress_dialog.dart';
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/widget.dart';

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

  void _login() async {
    bool isGood = true;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: '正在登录学校一站式',
      max: 100,
      hideValue: true,
      completed: Completed(
        completedMsg: "登录成功",
        closedDelay: 2500,
      ),
      error: ErrorSignal(
        closedDelay: 2500,
      ),
    );
    try {
      await ses.loginEhall(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
        onResponse: (int number, String status) =>
            pd.update(msg: status, value: number),
      );
    } catch (e) {
      isGood = false;
      pd.update(value: -1, msg: e.toString());
    }
    if (!mounted) return;
    if (isGood == true) {
      addUser("idsAccount", _idsAccountController.text);
      addUser("idsPassword", _idsPasswordController.text);
      await ses.getInformation();
      if (mounted) {
        if (pd.isOpen()) {
          pd.close();
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Temporary symbol of watermeter.
          const CircleAvatar(
            backgroundImage: AssetImage("assets/Login-Background.jpg"),
            radius: 60.0,
          ),
          const SizedBox(height: 15.0),
          const Text('请登录 Watermeter',
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
              onPressed: () {
                if (_idsAccountController.text.length == 11 &&
                    _idsPasswordController.text.isNotEmpty) {
                  _login();
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
                  IDSCookieJar.deleteAll().then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('清理缓存成功'),
                      ),
                    ),
                  );
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
