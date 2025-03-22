// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library session.

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

Rx<SessionState> state = SessionState.none.obs;
RxString error = "".obs;
List<BorrowData> borrowList = [];

Future<void> Function() refreshBorrowList =
    () => LibrarySession().getBorrowList();

int get dued => borrowList.where((element) => element.lendDay < 0).length;
int get notDued => borrowList.where((element) => element.lendDay >= 0).length;

class LibrarySession extends IDSSession {
  static String token = "";
  static String groupCode = "";

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

  Options get header => Options(
        headers: {
          HttpHeaders.cookieHeader: "jwt=$token; jwtHeader=jwtOpacAuth",
          "groupCode": groupCode.isEmpty ? "undefined" : groupCode,
          "jwtOpacAuth": token,
          HttpHeaders.refererHeader: "https://findxidian.libsp.cn/",
          HttpHeaders.hostHeader: "findxidian.libsp.cn",
        },
      )..contentType = "application/json;charset=utf-8";

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
    ).then((value) {
      if (value.data["data"] != null && value.data["data"]["list"] != null) {
        return value.data["data"]["list"];
      } else {
        return [];
      }
    });

    return List<BookInfo>.generate(
      rawData.length ?? 0,
      (index) => BookInfo.fromJson(rawData[index]),
    );
  }

  static String bookCover(String isbn) =>
      "http://124.90.39.130:18080/xdhyy_book//api/bookCover/getBookCover.html?isbn=$isbn";

  Future<String> renew(int loanId) async {
    return await dio
        .post(
          "https://findxidian.libsp.cn/find/lendbook/reNew",
          data: {
            "loanIds": [loanId]
          },
          options: header,
        )
        .then(
          (value) => value.data["data"]["result"]?.toString() ?? "遇到错误",
        );
  }

  Future<void> getBorrowList() async {
    if (state.value == SessionState.fetching) {
      return;
    }
    log.info(
      "[LibrarySession][getBorrowList] "
      "Getting borrow list",
    );

    try {
      state.value = SessionState.fetching;
      if (token.isEmpty) {
        await initSession();
      }

      if (groupCode.isEmpty) {
        groupCode = await dio
            .post(
              "https://findxidian.libsp.cn/find/homePage/getGroupCode",
              data: {"mappingPath": ""},
              options: header,
            )
            .then((value) => value.data["data"]["groupCode"]);
      }

      var rawData = await dio
          .post(
            "https://findxidian.libsp.cn/find/loanInfo/loanList",
            data: {
              "page": 1,
              "rows": 999,
              "searchType": 1,
              "searchContent": "",
              "sortType": 0,
              "startDate": null,
              "endDate": null
            },
            options: header,
          )
          .then((value) => value.data["data"]["searchResult"]);
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

  @override
  Future<void> initSession() async {
    log.info(
      "[LibrarySession][initSession] "
      "Initalizing Library Session",
    );

    token = "";

    try {
      String destinationURL =
          "https://findxidian.libsp.cn/find/sso/login/xidian/0";
      String location = await checkAndLogin(
        target: "https://tyrzfw.chaoxing.com/auth/xidian/cas/index",
        sliderCaptcha: (String cookieStr) =>
            SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
      );
      var response = await dio.get(location);

      while (response.headers[HttpHeaders.locationHeader] != null) {
        location = response.headers[HttpHeaders.locationHeader]![0];
        log.info(
          "[LibrarySession][initSession] "
          "Received location: $location.",
        );
        response = await dio.get(location);
      }

      // God damn, it use js to redirect...
      String toDeal = response.data.toString();
      String data = RegExp(r'data: "(?<data>.*)",')
          .firstMatch(toDeal)!
          .namedGroup("data")!;
      int time = int.parse(RegExp(r'time: (?<time>[0-9]*),')
          .firstMatch(toDeal)!
          .namedGroup("time")!);
      String enc =
          RegExp(r'enc: "(?<enc>.*)",').firstMatch(toDeal)!.namedGroup("enc")!;
      String name = RegExp(r'displayName: "(?<name>.*)",')
          .firstMatch(toDeal)!
          .namedGroup("name")!;
      int userRole = int.parse(RegExp(r'userRole: (?<userRole>[0-9]{1}),')
          .firstMatch(toDeal)!
          .namedGroup("userRole")!);

      var isSuccess = await dio.get(
        "https://tyrzfw.chaoxing.com/auth/xidian/cas/login",
        queryParameters: {
          "data": data,
          "time": time,
          "enc": enc,
          "displayName": name,
          "userRole": userRole,
          "group1": null,
          "mobilePhone": null,
        },
      ).then((value) => jsonDecode(value.data));

      if (!isSuccess["status"]) {
        throw NotFetchLibraryException(
            message: "Login failed: ${isSuccess["status"]}");
      }

      response = await dio.get(destinationURL, queryParameters: {
        "data": data,
        "time": time,
        "enc": enc,
      });

      RegExp tokenExp = RegExp(r"jwt=(?<jwt>.*)&");

      while (response.headers[HttpHeaders.locationHeader] != null) {
        location = response.headers[HttpHeaders.locationHeader]![0];
        token = tokenExp.firstMatch(location)?.namedGroup("jwt") ?? "";

        log.info(
          "[LibrarySession][initSession] "
          "Received location: $location.",
        );
        response = await dio.get(location, options: header);
      }

      if (token.isEmpty) {
        throw NotFetchLibraryException();
      }
    } catch (e, s) {
      log.handle(e, s);
      if (e is NotFetchLibraryException) {
        rethrow;
      }
      throw NotFetchLibraryException();
    }
  }
}

class NotFetchLibraryException implements Exception {
  final String message;
  NotFetchLibraryException({this.message = "Error detected."});
}
