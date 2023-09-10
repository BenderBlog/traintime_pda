// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
/*
// import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:watermeter/repository/network_session.dart';

class ExperimentSessoionTransformer extends BackgroundTransformer {
  @override
  Future<String> transformRequest(RequestOptions options) async {
    developer.log("Encoding...", name: "GBKTransformer");
    String type = await CharsetConverter.availableCharsets().then((value) =>
        value
            .firstWhere((element) => element.contains(RegExp(r'gb18030|GBK'))));

    /// Encode the headers, in case cookies contains Chinese Charactor
    for (var i in options.queryParameters.keys) {
      List<String> decoded = [];
      for (var j in options.queryParameters[i]!) {
        var encode = await CharsetConverter.encode(type, j);
        decoded.add(await CharsetConverter.decode(type, encode));
      }
      options.queryParameters[i] = decoded;
    }

    /// Data no need to encode, maybe.
    developer.log("Encoded queryParameters", name: "GBKTransformer");

    return super.transformRequest(options);
  }

  @override
  Future transformResponse(
      RequestOptions options, ResponseBody responseBody) async {
    developer.log("Decoding...", name: "GBKTransformer");

    /// Decode the headers, in case cookies contains Chinese Charactor
    for (var i in responseBody.headers.keys) {
      if (i.contains('cookie')) {
        developer.log(
          "Decoding $i = ${responseBody.headers[i]!}...",
          name: "ExperimentSessoionTransformer",
        );
        int index = responseBody.headers[i]!.lastIndexWhere((element) => element.contains('PhyEws_StuName'));
        responseBody.headers[i]![index] = "PhyEws_StuName";
        for (var j in ) {
          if (j.contains("")) {
            var encode = await CharsetConverter.encode(utf, j);
            decoded.add(await CharsetConverter.decode(iso, encode));
          }
          break;
        }
        developer.log("Decoding $i = $decoded", name: "GBKTransformer");
        responseBody.headers[i] = decoded;
      }
    }

    /// TODO: Decode more
    developer.log("Decoded", name: "GBKTransformer");
    return super.transformResponse(options, responseBody);
  }
}

class ExperimentSession extends NetworkSession {
  @override
  Dio get dio => super.dio..transformer = ExperimentSessoionTransformer();
  // ..options.requestEncoder = (request, options) {};

  Future<void> login() async {
    if (await NetworkSession.isInSchool() == false) {
      throw NotSchoolNetworkException;
    }
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
    print(loginResponse.data);
    if (loginResponse.statusCode != 302) {
      throw LoginFailedException();
    } else {
      print(
          "http://wlsy.xidian.edu.cn/${loginResponse.headers["Location"]![0]}");
      dio
          .get(
              "http://wlsy.xidian.edu.cn/${loginResponse.headers["Location"]![0]}")
          .then(
            (value) => print(value.data),
          );
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