/*
Library session.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Thanks xidian-script and libxdauth!

WTF did you know, you goddamn power of electricity?
*/

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class LibrarySession extends IDSSession {
  int userId = 0;
  String token = "";

  Future<List<BorrowData>> getBorrowList() async {
    if (userId == 0 && token == "") {
      await initSession();
    }
    var rawData = await dio.post(
      "https://zs.xianmaigu.com/xidian_book/api/borrow/getBorrowList.html",
      data: {
        "libraryId": 5,
        "userId": userId,
        "token": token,
        "cardNumber": preference.getString(preference.Preference.idsAccount),
        "page": 1,
      },
    ).then((value) => value.data["data"]);

    return List<BorrowData>.generate(
        rawData.length, (index) => BorrowData.fromJson(rawData[index]));
  }

  Future<void> initSession() async {
    var response = await checkAndLogin(
      target: "https://mgce.natapp4.cc/api/index/casLoginDo.html?"
          "libraryId=5&source=xdbb",
    );
    RegExp matchJson = RegExp(r'wx.miniProgram.postMessage(.*);');
    String result = matchJson
            .firstMatch(response.data)?[0]!
            .replaceFirst("wx.miniProgram.postMessage(", "")
            .replaceFirst("data", "\"data\"")
            .replaceFirst(");", "") ??
        "";

    developer.log("result is $result", name: "LibrarySession");

    var toGet = jsonDecode(result);

    userId = toGet["data"]["id"];
    token = toGet["data"]["token"];
  }
}

class NotFetchLibraryException implements Exception {}
