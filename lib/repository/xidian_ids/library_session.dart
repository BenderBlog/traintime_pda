// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library session.

import 'dart:io';
import 'dart:convert';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

Rx<SessionState> state = SessionState.none.obs;
RxString error = "".obs;
List<BorrowData> borrowList = [];

Future<void> Function() refreshBorrowList =
    () => LibrarySession().getBorrowList();

int get dued => borrowList.where((element) => element.lendDay < 0).length;
int get notDued => borrowList.where((element) => element.lendDay >= 0).length;

class LibrarySession extends IDSSession {
  static int userId = 0;
  static String userBarcode = "";
  static String token = "";

  /* Note 1: Search book pattern, no need to implement.
      POST https://zs.xianmaigu.com/xidian_book/api/search/getSearchBookType.html
      body { "libraryId": 5 }
    
    Note 2: 
      Scan to borrow book and transfer borrow book will not supported, 
      since I am not an official app, these function may lead me trouble:-P

      All I want to tell you, is the loanBook.html and borrow.html, that's it.
      And why Wechat's library app allows to scan the picture?

    Note 3: 
      Search the book's info does not require login.
      You can use it in SPM class...
  */

  Future<List<BookInfo>> searchBook(String searchWord, int page) async {
    if (searchWord.isEmpty) return [];
    var rawData = await dio.post(
      "https://shuwo.xidian.edu.cn/xidian_book/api/search/list.html",
      data: {
        "libraryId": 5,
        "searchWord": searchWord,
        "searchFiled": "title",
        "page": page,
        "searchLocationStatus": 1,
      },
    ).then((value) => value.data["data"]["list"] ?? []);

    return List<BookInfo>.generate(
      rawData.length ?? 0,
      (index) => BookInfo.fromJson(rawData[index]),
    );
  }

  static String bookCover(String isbn) =>
      "http://124.90.39.130:18080/xdhyy_book//api/bookCover/getBookCover.html?isbn=$isbn";

  Future<String> renew(BorrowData toUse) async {
    return await dio.post(
      "https://shuwo.xidian.edu.cn/xidian_book/api/borrow/renewBook.html",
      data: {
        "libraryId": 5,
        "userId": userId,
        "token": token,
        "cardNumber": preference.getString(preference.Preference.idsAccount),
        "barNumber": toUse.barcode,
        "bookName": toUse.title,
        "isbn": toUse.isbn,
        "author": toUse.author,
      },
    ).then(
      (value) => value.data["msg"]?.toString() ?? "遇到错误",
    );
  }

  Future<void> getBorrowList() async {
    if (state.value == SessionState.fetching) {
      return;
    }
    log.i(
      "[LibrarySession][getBorrowList] "
      "Getting borrow list",
    );

    try {
      state.value = SessionState.fetching;
      if (userId == 0 && token == "") {
        await initSession();
      }
      if (userBarcode == "") {
        userBarcode = await dio.post(
          "https://shuwo.xidian.edu.cn/xidian_book/api/borrow/getUserInfo",
          data: {
            "libraryId": 5,
            "userId": userId,
            "token": token,
            "cardNumber":
                preference.getString(preference.Preference.idsAccount),
          },
        ).then(
          (value) {
            if (value.data["code"] != 1) {
              throw NotFetchLibraryException(message: value.data["msg"]);
            }
            return value.data["data"]["userBarcode"];
          },
        );
      }
      var rawData = await dio.post(
        "https://shuwo.xidian.edu.cn/xidian_book/api/borrow/getBorrowList.html",
        data: {
          "libraryId": 5,
          "userId": userId,
          "token": token,
          "cardNumber": userBarcode,
          "page": 1,
        },
      ).then((value) => value.data["data"]);
      borrowList.clear();
      borrowList.addAll(List<BorrowData>.generate(
        rawData.length,
        (index) => BorrowData.fromJson(rawData[index]),
      ));
      state.value = SessionState.fetched;
    } catch (e) {
      error.value = e.toString();
      state.value = SessionState.error;
    }
  }

  Future<void> initSession() async {
    log.i(
      "[LibrarySession][initSession] "
      "Initalizing Library Session",
    );
    try {
      String location = await checkAndLogin(
        target: "https://mgce.natapp4.cc/api/index/casLoginDo.html?"
            "libraryId=5&source=xdbb",
        sliderCaptcha: (p0) async {},
      );
      var response = await dio.get(location);

      while (response.headers[HttpHeaders.locationHeader] != null) {
        location = response.headers[HttpHeaders.locationHeader]![0];
        log.i(
          "[LibrarySession][initSession] "
          "Received location: $location.",
        );
        response = await dio.get(location);
      }

      RegExp matchJson = RegExp(r'wx.miniProgram.postMessage(.*);');
      String result = matchJson
              .firstMatch(response.data)?[0]!
              .replaceFirst("wx.miniProgram.postMessage(", "")
              .replaceFirst("data", "\"data\"")
              .replaceFirst(");", "") ??
          "";

      log.i(
        "[LibrarySession][initSession] "
        "Result is $result.",
      );

      var toGet = jsonDecode(result);

      userId = toGet["data"]["id"];
      token = toGet["data"]["token"];
    } catch (e) {
      throw NotFetchLibraryException();
    }
  }
}

class NotFetchLibraryException implements Exception {
  final String message;
  NotFetchLibraryException({this.message = "发生错误"});
}
