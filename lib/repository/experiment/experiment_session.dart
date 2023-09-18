// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/experiment/experiment_dio_transfer.dart';

class ExperimentSession extends NetworkSession {
  @override
  Dio get dio => Dio()
    ..interceptors.add(alice.getDioInterceptor())
    ..transformer = ExperimentDioTransformer()
    ..options.followRedirects = false
    ..options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;

  Future<List<ExperimentData>> getData() async {
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
      var data = await dio
          .get("http://wlsy.xidian.edu.cn/PhyEws/student/select.aspx",
              options: Options(
                headers: {
                  HttpHeaders.cookieHeader: cookieStr,
                  HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
                },
              ))
          .then(
            (value) => value.data,
          );
      RegExp regExp = RegExp(
        r'<td class="forumRow" height="25"><span>(?<id>[0-9]{1,2})</span></td>'
        r'<td class="forumRow" height="25"><a class="linkSmallBold" target="_new">(?<name>((?!《物理实验》)(?!下载).*?)（[0-9]学时）)</a></td>'
        r'<td class="forumRow" align="center" height="25"><span>(?<week>[0-9]{1,2})</span></td>'
        r'<td class="forumRow" height="25"><span>(?<time>星期(.*)([0-2][0-9]:[0-5][0-9])～([0-2][0-9]:[0-5][0-9]))</span></td>'
        r'<td class="forumRow" height="25"><span>(?<date>([0-9]{1,2}/[0-9]{1,2}/[0-9]{4}))</span></td>'
        r'<td class="forumRow" align="center" height="25"><span>(?<place>([A-F]([0-999]{3,3})))</span></td>'
        r'<td class="forumRow" height="25"><a class="linkSmallBold" target="_new">大学物理实验</a></td>'
        r'<td class="forumRow" height="25"><span>(?<score>(.*))</span></td><td class="forumRow" height="25"><span></span></td>'
        r'<td class="forumRow" height="25"><span>(?<note>([0-9]{1,3}页))</span></td>',
      );

      var expInfo = regExp.allMatches(data).toList();
      return List<ExperimentData>.generate(
        expInfo.length,
        (index) => ExperimentData(
          name: expInfo[index].namedGroup('name')!,
          score: expInfo[index].namedGroup('score')!,
          classroom: expInfo[index].namedGroup('place')!,
          date: expInfo[index].namedGroup('date')!,
          timeStr: expInfo[index].namedGroup('time')!,
          reference: expInfo[index].namedGroup("note")!,
        ),
      );
    }
  }
}

class LoginFailedException implements Exception {}

class ExperimentClosedException implements Exception {}
