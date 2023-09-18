// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/experiment/experiment_dio_transfer.dart';
import 'package:watermeter/repository/network_session.dart';

class ExperimentSession extends NetworkSession {
  @override
  Dio get dio => Dio()
    ..interceptors.add(alice.getDioInterceptor())
    ..transformer = ExperimentDioTransformer()
    ..options.followRedirects = false
    ..options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;

  Future<void> getData() async {
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
      String cookieStr = "";
      for (String i
          in loginResponse.headers[HttpHeaders.setCookieHeader] ?? []) {
        developer.log(
          i,
          name: "ExperimentSession",
        );
        if (i.contains("PhyEws_StuName")) {
          /// This guy find out the secret.
          cookieStr += "PhyEws_StuName=waterfloatinggenderly; ";
        } else if (i.contains('HttpOnly')) {
          continue;
        } else {
          cookieStr += '${i.split(';')[0]}; ';
        }
      }
      developer.log(
        cookieStr,
        name: "ExperimentSession",
      );
      var d = await dio
          .get("http://wlsy.xidian.edu.cn/PhyEws/student/select.aspx",
              options: Options(
                headers: {
                  HttpHeaders.cookieHeader: cookieStr,
                  HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
                },
              ))
          .then((value) => value.data);
      developer.log(
        d.toString(),
        name: "ExperimentSession",
      );
    }
  }
}

class LoginFailedException implements Exception {}

class ExperimentClosedException implements Exception {}
