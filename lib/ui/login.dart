/*
Login window of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/dataStruct/user.dart';
import 'package:watermeter/ui/home.dart';
import 'package:watermeter/communicate/IDS/ehall.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({Key? key}) : super(key: key);

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  /// Sport Password Text Editing Controller
  final TextEditingController _sportPasswordController = TextEditingController.fromValue(
    TextEditingValue(
      text: "123456",
      selection: TextSelection.fromPosition(
        const TextPosition(
          affinity: TextAffinity.downstream,
          offset: "123456".length,
         )
      ),
    )
  );
  /// The rest of Text Editing Controller
  final TextEditingController _idsAccountController = TextEditingController();
  final TextEditingController _idsPasswordController = TextEditingController();
  /// State observer.
  final GlobalKey _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("请登录到 WaterMeter"),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _idsAccountController,
                    decoration: const InputDecoration(labelText: "学号", prefixIcon: Icon(Icons.person)),
                    validator: (value) => value!.length == 11 ? null : "学号必须11位",
                  ),
                  TextFormField(
                    controller: _idsPasswordController,
                    decoration: const InputDecoration(labelText: "一站式登录密码", prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    validator: (value) => value!.isNotEmpty ? null : "请输入密码",
                  ),
                  TextFormField(
                    controller: _sportPasswordController,
                    decoration: const InputDecoration(labelText: "体适能密码", prefixIcon: Icon(Icons.lock),),
                    obscureText: true,
                    validator: (value) => value!.isNotEmpty ? null : "请输入密码",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: ElevatedButton(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("登录"),
                ),
                onPressed: () {
                  if ((_formKey.currentState as FormState).validate()) {
                    _login();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sesLogin(BuildContext context, VoidCallback onSuccess, Function(dynamic) onFailure) async {
    try {
      await ses.loginEhall(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
      );
    } catch (e) {
      onFailure(e);
    }
    if (await ses.isLoggedIn()) {
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
          addUser("sportPassword", _sportPasswordController.text);
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
