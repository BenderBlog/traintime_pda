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
  static int userId = 0;
  static String token = "";

  /* Note 1: Search book pattern, no need to implement.
    POST https://zs.xianmaigu.com/xidian_book/api/search/getSearchBookType.html
    body { "libraryId": 5 }

    {
      "code": 1,
      "msg": "",
      "url": "",
      "data": [{
        "type": "wrd",
        "typeName": "任意词"
      }, {
        "type": "wti",
        "typeName": "题名"
      }, {
        "type": "wau",
        "typeName": "著者"
      }, {
        "type": "iss",
        "typeName": "ISSN"
      }, {
        "type": "isb",
        "typeName": "ISBN"
      }, {
        "type": "bar",
        "typeName": "条码"
      }, {
        "type": "cal",
        "typeName": "索书号"
      }, {
        "type": "clc",
        "typeName": "中图分类号"
      }, {
        "type": "wpu",
        "typeName": "出版社"
      }, {
        "type": "wsu",
        "typeName": "主题词"
      }],
      "sysDateTime": 1689748355145
    }
  */

  Future<List<BookInfo>> searchBook(String searchWord, int page) async {
    if (userId == 0 && token == "") {
      await initSession();
    }
    var rawData = await dio.post(
      "https://zs.xianmaigu.com/xidian_book/api/search/list.html",
      data: {
        "libraryId": 5,
        "searchWord": searchWord,
        "searchFiled": "wrd",
        "page": page,
        "searchLocationStatus": 1,
      },
    ).then((value) => value.data["data"]["list"]);

    developer.log(rawData.toString());

    return List<BookInfo>.generate(
      rawData.length ?? 0,
      (index) => BookInfo.fromJson(rawData[index]),
    );
  }

  Future<List<BookLocation>> getBookLocation(BookInfo toUse) async {
    if (userId == 0 && token == "") {
      await initSession();
    }
    var rawData = await dio.post(
      "https://zs.xianmaigu.com/xidian_book/api/search/getBookByDocNum.html",
      data: {
        "libraryId": 5,
        "userId": userId,
        "token": token,
        "cardNumber": preference.getString(preference.Preference.idsAccount),
        "docNumber": toUse.docNumber,
        "base": toUse.base,
        "searchLocationStatus": 1,
        "searchCode": toUse.searchCode,
      },
    ).then((value) => value.data["data"]);

    return List<BookLocation>.generate(
      rawData.length,
      (index) => BookLocation.fromJson(rawData[index]),
    );
  }

  /* Note 2: 
      Scan to borrow book and transfer borrow book will not supported, 
      since I am not an official app, these function may lead me trouble:-P

      All I want to tell you, is the loanBook.html and borrow.html, that's it.
      And why Wechat's library app allows to scan the picture?
  */

  static String bookCover(String isbn) =>
      "http://124.90.39.130:18080/xdhyy_book//api/bookCover/getBookCover.html?isbn=$isbn";

  Future<String> renew(BorrowData toUse) async {
    return await dio.post(
      "https://zs.xianmaigu.com/xidian_book/api/borrow/renewBook.html",
      data: {
        "libraryId": 5,
        "userId": userId,
        "token": token,
        "cardNumber": preference.getString(preference.Preference.idsAccount),
        "barNumber": toUse.barNumber,
        "bookName": toUse.bookName,
        "isbn": toUse.isbn,
        "libraryCode": toUse.libraryCode,
        "author": toUse.author,
        "docNumber": toUse.docNumber,
      },
    ).then(
      (value) => value.data["msg"]?.toString() ?? "遇到错误",
    );
  }

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
        "page": 0,
      },
    ).then((value) => value.data["data"]);

    return List<BorrowData>.generate(
      rawData.length,
      (index) => BorrowData.fromJson(rawData[index]),
    );
  }

  Future<void> initSession() async {
    try {
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
    } catch (e) {
      throw NotFetchLibraryException();
    }
  }
}

class NotFetchLibraryException implements Exception {}
