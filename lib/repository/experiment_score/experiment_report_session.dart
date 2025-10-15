// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';

class ExperimentReportSession extends NetworkSession {
  // Cache the Dio instance to avoid recreating it
  Dio? _dioInstance;

  @override
  Dio get dio {
    if (_dioInstance != null) {
      return _dioInstance!;
    }

    _dioInstance = Dio()
      ..interceptors.add(logDioAdapter)
      ..options.contentType = Headers.formUrlEncodedContentType
      ..options.followRedirects = false
      ..options.responseDecoder = (responseBytes, options, responseBody) async {
        // Check if the response is JSON by looking at the first character
        // JSON responses start with '{' or '['
        if (responseBytes.isNotEmpty && 
            (responseBytes[0] == 0x7B || responseBytes[0] == 0x5B)) {
          // This is JSON, decode as UTF-8
          return utf8.decode(responseBytes);
        }
        
        // For HTML pages, use GBK/GB18030 decoding
        String gbk = await CharsetConverter.availableCharsets().then(
          (value) => value.firstWhere((element) => element.contains("18030")),
        );
        return await CharsetConverter.decode(
          gbk,
          Uint8List.fromList(responseBytes),
        );
      }
      ..options.validateStatus = (status) =>
          status != null && status >= 200 && status < 400;

    return _dioInstance!;
  }

  /// Get the score image from the report system
  Future<Map<String, String>> getScoreImageUrls(
    String account,
    String pwd,
  ) async {
    final commonHeaders = {
      HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
      HttpHeaders.userAgentHeader:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
      HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
      HttpHeaders.connectionHeader: 'keep-alive',
      'Origin': 'http://wlsy.xidian.edu.cn',
      HttpHeaders.refererHeader:
          'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/?id=stu',
    };

    final getHeaders = {
      ...commonHeaders,
      HttpHeaders.acceptHeader:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Upgrade-Insecure-Requests': '1',
      'X-Requested-With': 'XMLHttpRequest',
    };

    final postHeaders = {
      ...commonHeaders,
      HttpHeaders.contentTypeHeader:
          'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      HttpHeaders.acceptHeader: '*/*',
    };

    // Simple Cookie string manager
    String cookieStr = '';
    String sid = '';

    log.debug(
      "[experiment_report_session][getScoreImageUrls] "
      "Send the first GET request",
    );

    var initQuest = await dio.get(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/?id=stu',
      options: Options(headers: getHeaders),
    );

    // Extract the Session ID from html
    var responseData = initQuest.data.toString();
    var sidRegex = RegExp(r'(\d+_[a-zA-Z0-9]+111D[a-fA-F0-9]+)');
    var match = sidRegex.firstMatch(responseData);
    if (match != null) {
      sid = match.group(1) ?? '';
      cookieStr = 'UNI_GUI_SESSION_ID=$sid';
    }

    // Validate that we got a valid session ID
    if (sid.isEmpty) {
      log.error(
        "[experiment_report_session][getScoreImageUrls]",
        "Failed to extract session ID from response",
      );
      throw Exception('Failed to extract session ID from login page');
    }

    log.debug(
      "[experiment_report_session][getScoreImageUrls] "
      "[initQuest Data - Length: ${responseData.length}]\n${responseData.substring(0, responseData.length > 500 ? 500 : responseData.length)}...\n"
      "[Cookie String]\n$cookieStr\n"
      "[Session ID]\n$sid\n",
    );

    // Send machine info to sever
    var postData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=cinfo&ci=br%3D33%3Bos%3D4%3Bbv%3D140%3Bww%3D2048%3Bwh%3D1018&_S_ID=$sid&_seq_=0&_uo_=O0';

    await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: postData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send Move event
    log.debug(
      "[experiment_report_session][getScoreImageUrls] "
      "Send the second POST request (Move)",
    );

    var movePostData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=move&this=O0&x=868&y=381&_S_ID=$sid&_seq_=1&_uo_=O0';

    await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: movePostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send Activate event
    log.debug(
      "[experiment_report_session][getScoreImageUrls] "
      "Send the third POST request (Activate)",
    );

    var activatePostData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=activate&this=O0&_S_ID=$sid&_seq_=2&_uo_=O0';

    await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: activatePostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send resize event
    log.debug(
      "[experiment_report_session][getScoreImageUrls] "
      "Send the fourth POST request (Resize)",
    );

    var resizePostData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=resize&this=O0&w=311&h=255&_S_ID=$sid&_seq_=3&_uo_=O0';

    await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: resizePostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send click event, also as sign in
    log.debug(
      "[experiment_report_session][getScoreImageUrls] "
      "Send the fifth POST request (Click)",
    );

    var clickPostData =
        'Ajax=1&IsEvent=1&Obj=O1F&Evt=click&this=O1F&_S_ID=$sid&_fp_=%26O17%3D%25020%2502%2502$account%26O1B%3D%25020%2502%2502$pwd&_seq_=4&_uo_=O0';

    var clickResponse = await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: clickPostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Get the cookie sid
    var clickSetCookieHeaders = clickResponse.headers['set-cookie'];
    if (clickSetCookieHeaders != null && clickSetCookieHeaders.isNotEmpty) {
      for (var header in clickSetCookieHeaders) {
        if (header.startsWith('sid=')) {
          var sidValue = header.split(';')[0].split('=')[1];
          cookieStr = 'UNI_GUI_SESSION_ID=$sid; sid=$sidValue';
          log.debug(
            "[experiment_report_session][getScoreImageUrls] "
            "[Updated Cookie String]\n$cookieStr",
          );
          break;
        }
      }
    } else {
      log.error(
        "[experiment_report_session][getScoreImageUrls] "
        "[Updated Cookie String]\nclickResponse.headers['set-cookie'] is null",
      );
    }

    // Get the score information
    log.debug(
      "[experiment_report_session][getScoreImageUrls] "
      "Send the final GET request",
    );

    var dataResponse = await dio.get(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      queryParameters: {
        'IsEvent': '1',
        'Obj': 'OA7',
        'Evt': 'data',
        '_dc': DateTime.now().millisecondsSinceEpoch,
        'start': '0',
        'limit': '25',
        'options': '1',
        'page': '1',
      },
      options: Options(
        headers: {
          ...commonHeaders,
          'X-Requested-With': 'XMLHttpRequest',
          'UniSessionId': sid,
          '_S_ID': sid,
          HttpHeaders.acceptHeader: '*/*',
          HttpHeaders.cookieHeader: cookieStr,
        },
      ),
    );

    // Parse the information and get the result
    Map<String, String> experimentInfo = _extractExperimentInfo(
      dataResponse.data,
    );

    log.debug('[experiment_report_session][getScoreImageUrls]', experimentInfo);

    return experimentInfo;
  }

  /// Extract the score information from the raw data
  Map<String, String> _extractExperimentInfo(dynamic responseData) {
    Map<String, String> result = {};

    try {
      // Process the escape character
      String jsonString = responseData
          .toString()
          .replaceAll(r'\x3C', '<')
          .replaceAll(r'\x3E', '>');

      // parse the json data
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      List<dynamic> rows = jsonData['rows'] ?? [];

      for (var row in rows) {
        String experimentName = row['1'] ?? '';

        String imageHtml = row['2'] ?? '';

        RegExp srcRegex = RegExp(r'src="([^"]+)"');
        Match? match = srcRegex.firstMatch(imageHtml);

        if (match != null && experimentName.isNotEmpty) {
          String imageUrl = match.group(1) ?? '';

          if (imageUrl.startsWith('/')) {
            imageUrl = 'http://wlsy.xidian.edu.cn$imageUrl';
          }
          result[experimentName] = imageUrl;
        }
      }

      if (result.isEmpty) {
        log.error(
          '[experiment_report_session][_extractExperimentInfo]',
          'Result is empty.',
        );
        throw Exception("Fail to get url from Report Server");
      }
    } catch (e) {
      log.error(
        '[experiment_report_session][_extractExperimentInfo]',
        'Fail to parse JSON: $e',
      );
      throw Exception("Fail to parse JSON: $e");
    }

    return result;
  }

  /// Extract the score from urls
  Future<Uint8List> _downloadImageBytes(String url) async {
    try {
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      }

      log.error(
        '[experiment_report_session][_downloadImageBytes]',
        'HTTP ${response.statusCode} for $url',
      );

      throw Exception('HTTP ${response.statusCode} for $url');
    } catch (e) {
      log.error(
        '[experiment_report_session][_downloadImageBytes]',
        'Failed to download $url: $e',
      );
      throw Exception('Failed to download $url: $e');
    }
  }

  /// Download image bytes (public method for MD5 calculation)
  Future<Uint8List> downloadImageBytes(String url) async {
    return await _downloadImageBytes(url);
  }

  /// Download the images from urls and turn it into Image Object
  Future<img.Image> downloadAndDecodeImage(String url) async {
    final bytes = await _downloadImageBytes(url);
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      log.error(
        '[experiment_report_session][downloadAndDecodeImage]',
        'Cannot decode image from $url',
      );
      throw FormatException('Cannot decode image from $url');
    }
    return decoded;
  }
}
