/*
Login window of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/dataStruct/user.dart';
import 'package:watermeter/ui/home.dart';
import 'package:watermeter/communicate/IDS/ids.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({Key? key}) : super(key: key);

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  String idsName = "";
  String idsPass = "";
  String sportPass = "123456";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("请登录到 WaterMeter"),
      ),
      body: Column(
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
                labelText: "学号",
                prefixIcon: Icon(Icons.person)
            ),
            onChanged: (String value) => idsName = value,
          ),
          TextField(
            decoration: const InputDecoration(
                labelText: "一站式登录密码",
                prefixIcon: Icon(Icons.lock)
            ),
            obscureText: true,
            onChanged: (String value) => idsPass = value,
          ),
          TextField(
            decoration: const InputDecoration(
                labelText: "体适能，默认 123456，没改的就不要填了",
                prefixIcon: Icon(Icons.lock)
            ),
            obscureText: true,
            onChanged: (String value) => sportPass = value,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("登录"),
                    ),
                    onPressed: () async {
                      await addUser("idsAccount", idsName);
                      await addUser("idsPassword", idsPass);
                      /// Temporary this way :-P
                      await addUser("sportPassword", sportPass);
                      ids.login(username: user["idsAccount"]!, password: user["idsPassword"]!, target: "http://ehall.xidian.edu.cn/login?service=http://ehall.xidian.edu.cn/new/index.html");
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return const HomePage();
                        }),
                      );

                    },
                  ),
          ),
        ],
      ),
    );
  }
}
