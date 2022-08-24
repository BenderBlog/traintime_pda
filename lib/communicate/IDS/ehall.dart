/*
E-hall class, which get lots of useful data here.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:ffi';

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:watermeter/communicate/IDS/ids.dart';
import 'package:watermeter/communicate/general.dart';

class EhallSession extends IDSSession {

  Dio get _dio{
    Dio toReturn = Dio(BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
    ));
    toReturn.interceptors.add(CookieManager(IDSCookieJar));
    return toReturn;
  }

  @override
  Future<bool> isLoggedIn() async {
    var response = await _dio.get(
      "http://ehall.xidian.edu.cn/jsonp/userFavoriteApps.json",
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

  Future<String> useApp(String appID) async {
    return await _dio.get(
      "http://ehall.xidian.edu.cn/appShow",
      queryParameters: {'appId': appID},
      options: Options(
        followRedirects: false,
        validateStatus: (status) { return status! < 500; },
        headers: {
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        }
      )
    ).then((value) => value.headers['location']![0]);
  }

  /// 学生个人信息管理  4585275700341858



  /// 考试成绩        4768574631264620
  Future<void> getScore () async {
    Map<String,dynamic> querySetting =
      {
        'name': 'SFYX',
        'value': '1',
        'linkOpt': 'and',
        'builder': 'm_value_equal'
      };
    var firstPost = await useApp("4768574631264620");
    print(firstPost);
    var post = await _dio.get(firstPost);
    print(post);
    var getData = await _dio.post(
      "http://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do",
      data: {
        "*json": 1,
        "querySetting": json.encode(querySetting),
        "*order": '+XNXQDM,KCH,KXH',
        'pageSize':1000,
        'pageNumber': 1,
      },
    );
    print(getData);
  }

  /// 课程表 4770397878132218
  Future<void> getClasstable () async {
    var firstPost = await useApp("4770397878132218");
    print(firstPost);
    var post = await _dio.get(firstPost);
    print(post);
    String semesterCode = await _dio.post(
      "http://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
      options: Options(
        headers: {'Accept': 'application/json, text/javascript, */*; q=0.01'}
      )
    ).then((value) => value.data['datas']['dqxnxq']['rows'][0]['DM']);
    print(semesterCode);
    String termStartDay = await _dio.post(
      'http://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
      data: {
        'XN': '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
        'XQ': semesterCode.split('-')[2]
      },
      options: Options(
        headers: {'Accept': 'application/json, text/javascript, */*; q=0.01'}
      ),
    ).then((value)=>value.data['datas']['cxjcs']['rows'][0]["XQKSRQ"]);
    print(termStartDay);
    var qResult = await _dio.post(
      'http://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
      data: {'XNXQDM': semesterCode},
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json, text/javascript, */*; q=0.01'
        }
      )
    ).then((value) => value.data['datas']['xskcb']);
    print(qResult['extParams']['code'] == 1 ? qResult['rows'] : qResult['extParams']['msg']);
  }

}

class NotLoginException implements Exception {}

var ses = EhallSession();