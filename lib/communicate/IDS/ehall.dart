/*
E-hall class.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:watermeter/communicate/IDS/ids.dart';
import 'package:watermeter/communicate/general.dart';

class EhallSession extends IDSSession {

  final String _baseURL = "http://ehall.xidian.edu.cn/";

  Dio get _dio{
    Dio toReturn = Dio(BaseOptions(
      baseUrl: _baseURL,
      contentType: Headers.formUrlEncodedContentType,
    ));
    toReturn.interceptors.add(CookieManager(IDSCookieJar));
    return toReturn;
  }

  @override
  Future<bool> isLoggedIn() async {
    var response = await _dio.get(
      "jsonp/userFavoriteApps.json",
    );
    return response.data["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    bool forceReLogin = false
  }) async {
    if (await isLoggedIn() == false || forceReLogin == true){
      print("IsnotLogin");
      await super.login(
        username: username,
        password: password,
        target: "http://ehall.xidian.edu.cn/login?service=http://ehall.xidian.edu.cn/new/index.html"
      );
    }
  }

  /*
  Future<List<int>> getAppList({String searchKey = ""}) async {
    var appList = await _dio.get(
      "jsonp/serviceSearchCustom.json",
      queryParameters: {
        'searchKey': searchKey,
        'pageNumber': 1,
        'pageSize': 150,
        'sortKey': 'recentUseCount',
        'orderKey': 'desc'
      }
    );
    if (appList.data["hasLogin"] == false) {
      throw NotLoginException();
    } else {
      return appList.data["data"];
    }
  }

  /// TODO: Change int!
  Future<int> getAppID (String searchKey) async {
    var searchResult = await getAppList(searchKey: searchKey);
    if (searchKey.isEmpty){
      return 0;
    } else {
      return searchResult[0]['appId'];
    }
  }
  */

  Future<void> useApp(String appID) async => await _dio.get(
    "appShow",
    queryParameters: {'appId': appID},
    options: Options(
      headers: {
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
      }
    )
  );

}

class NotLoginException implements Exception {}

var ses = EhallSession();