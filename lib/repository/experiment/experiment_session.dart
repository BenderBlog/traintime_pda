// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
/*
// import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'dart:developer' as developer;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/experiment/experiment_cookie_manager.dart';

class ExperimentSession extends NetworkSession {
  @override
  Dio get dio => Dio()
    ..httpClientAdapter = NativeAdapter()
    ..interceptors.add(alice.getDioInterceptor())
    //..interceptors.add(ExperimentCookieManager(CookieJar()))
    ..options.followRedirects = false
    ..options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;

  Future<void> login() async {
    if (await NetworkSession.isInSchool() == false) {
      throw NotSchoolNetworkException;
    }

    developer.log(
      "get login in experiment_session",
      name: "ExperimentSession",
    );
    var loginResponse = await dio.post(
      'http://wlsy.xidian.edu.cn/PhyEws/default.aspx',
      data: '__EVENTTARGET=&__EVENTARGUMENT=&'
          '__VIEWSTATE=%2FwEPDwUKMTEzNzM0MjM0OWQYAQUeX19D'
          'b250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgEFD2xvZ2luMSRidG5Mb2dpbkOuzGVaztce4Ict7jsIJ0F5pUDb%2BsmSbCCrNVSBlPML&'
          '__VIEWSTATEGENERATOR=EE008CD9&'
          '__EVENTVALIDATION=%2FwEdAAcKecdPGDB%2BfW8Tyghx'
          '7AeSpOzeiNZ7aaEg5p6LqSa9cODI2bZwNtRxUKPkisVLf8l'
          '8Vv4WhRVIIhZlyYNJO%2BySrDKOhP%2B%2FYMNbVIh74hA2r'
          'CYnBBSTsX9SjxiYNNk%2B5kglM%2B6pGIq22Oi5mNu6u6eC2W'
          'EBfKAmATKwSpsOL%2FPNcRyi9l8Dnp6JamksyAzjhW4%3D&'
          'login1%24StuLoginID=22009200481&'
          'login1%24StuPassword=wlsyRunMea_02&'
          'login1%24UserRole=Student&'
          'login1%24btnLogin.x=28&'
          'login1%24btnLogin.y=14',
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    developer.log(
      loginResponse.data,
      name: "ExperimentSession",
    );
    if (loginResponse.statusCode != 302) {
      throw LoginFailedException();
    } else {
      String gbk = await CharsetConverter.availableCharsets().then(
          (value) => value.firstWhere((element) => element.contains("18030")));
      developer.log(
        "${loginResponse.headers["Location"]![0]} using $gbk",
        name: "ExperimentSession",
      );
      var d = await dio
          .get(
            "http://wlsy.xidian.edu.cn/${loginResponse.headers["Location"]![0]}",
          )
          .then(
            (value) async => value.data,
          );
      developer.log(d.toString());
    }
  }

  Future<void> getData() async {
    if (await NetworkSession.isInSchool() == false) {
      throw NotSchoolNetworkException;
    }
    var loginResponse = await dio
        .get(
          'http://wlsy.xidian.edu.cn/PhyEws/student/select.aspx',
        )
        .then((value) => value.data.toString());
    RegExp regExp = RegExp(
      r'<td class="forumRow" height="25"><a class="linkSmallBold"(.*?)target="_new">((?!《物理实验》)(?!下载).*?)（[0-9]学时）</a></td>'
      r'<td class="forumRow" align="center" height="25"><span>[0-9]{1,2}</span></td>'
      r'<td class="forumRow" height="25"><span>星期(.*?)((([01][0-9]|2[0-3]):[0-5][0-9])\-(([01][0-9]|2[0-3]):[0-5][0-9]))</span></td>'
      r'<td class="forumRow" height="25"><span>([0-9]{1,2}/[0-9]{1,2}/[0-9]{4})</span></td>'
      r'<td class="forumRow" align="center" height="25"><span>([A-F]([0-999]{3,3}))</span></td>',
    );
    for (var exp in regExp.allMatches(loginResponse)) {
      print(exp);
    }
  }
}

class LoginFailedException implements Exception {}

class ExperimentClosedException implements Exception {}
*/