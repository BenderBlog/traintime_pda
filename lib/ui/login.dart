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
import 'package:watermeter/dataStruct/user.dart';
import 'package:watermeter/communicate/general.dart';
import 'package:watermeter/ui/home.dart';
import 'package:watermeter/ui/weight.dart';
import 'package:watermeter/communicate/IDS/ehall.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({Key? key}) : super(key: key);

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  /// The rest of Text Editing Controller
  final TextEditingController _idsAccountController = TextEditingController();
  final TextEditingController _idsPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F6),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Temporary symbol of watermeter.
          const CircleAvatar(
            backgroundImage: AssetImage("assets/Login-Background.jpg"),
            radius: 60.0,
          ),
          const SizedBox(height: 15.0),
          const Text(
              '请登录 Watermeter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              )
          ),
          const SizedBox(height: 40.0),
          inputField(
            text: "学号",
            icon: const Icon(Icons.person),
            controller: _idsAccountController,
            isAutoFocus: true,
          ),
          const SizedBox(height: 20.0),
          inputField(
            text: "一站式登录密码",
            icon: const Icon(Icons.lock),
            controller: _idsPasswordController,
            isPassword: true,
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widthOfSquare),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA267AC),
                padding: const EdgeInsets.all(20.0),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(roundRadius)),
              ),
              child: const Text(
                "登录",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {
                if (_idsAccountController.text.length == 11 && _idsPasswordController.text.isNotEmpty) {
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
                } ,
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _sesLogin(
    BuildContext context,
    VoidCallback onSuccess,
    Function(dynamic) onFailure
  ) async {
    bool hadThrown = false;
    try {
      await ses.loginEhall(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
      );
    } catch (e) {
      hadThrown = true;
      onFailure(e);
    }
    if (await ses.isLoggedIn() && hadThrown == false) {
      onSuccess.call();
    } else {
      onFailure("登录因不明原因失败");
    }
  }

  void _login () async {
    print("准备登录 ${_idsAccountController.text} ${_idsPasswordController.text}");
    _sesLogin(
      context,
      () {
        if (mounted) {
          addUser("idsAccount", _idsAccountController.text);
          addUser("idsPassword", _idsPasswordController.text);

          /// Temporary solution.
          /// addUser("sportPassword", _sportPasswordController.text);
          ses.getInformation();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
          );
        }
      },
      (e) {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: const Text('登录失败'),
                content: Text("错误信息：$e"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("确定"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
        );
      },
    );
  }
}
