// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart';
import 'package:watermeter/model/xidian_ids/network_usage.dart';
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:html/parser.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:watermeter/repository/preference.dart' as prefs;

Rxn<NetworkUsage?> networkInfo = Rxn();
Rx<SessionState> schoolNetStatus = SessionState.none.obs;
var isError = "".obs;

// NetworkInfo is not controlled by schoolNetStatus, do remember
enum CurrentUserNetInfoState { fetching, fetched, notSchool, error, none }

Rxn<NetworkInfo?> currentUserNetInfo = Rxn();
Rx<CurrentUserNetInfoState> currentUserNetInfoStatus =
    CurrentUserNetInfoState.none.obs;

Future<void> update({
  Future<String> Function(List<int>)? captchaFunction,
}) async {
  log.info("[SchoolnetSession] Ready to fetch the schoolnet infos.");
  await SchoolnetSession().getNetworkUsage(captchaFunction: captchaFunction);
}

class SchoolnetSession extends NetworkSession {
  Dio get _dio => super.dio
    ..options.baseUrl = "https://zfw.xidian.edu.cn"
    ..options.headers = {"Host": "zfw.xidian.edu.cn"}
    ..options.contentType = Headers.formUrlEncodedContentType
    ..options.followRedirects = true;

  static Future<void> getCurrentUserLogin() async {
    final dio = Dio();
    currentUserNetInfoStatus.value = CurrentUserNetInfoState.fetching;
    if (await NetworkSession.isInSchool() == false) {
      currentUserNetInfoStatus.value = CurrentUserNetInfoState.notSchool;
      return;
    }
    try {
      final networkInfoResponse = await dio
          .get(
            'https://w.xidian.edu.cn/cgi-bin/rad_user_info',
            queryParameters: {
              'callback': 'jsonp',
              '_': DateTime.now().millisecondsSinceEpoch.toString(),
            },
            options: Options(responseType: ResponseType.plain),
          )
          .then((value) => value.data);
      final jsonString = networkInfoResponse.substring(
        6,
        networkInfoResponse.length - 1,
      );
      currentUserNetInfo.value = NetworkInfo.fromJson(jsonDecode(jsonString));
      currentUserNetInfoStatus.value = CurrentUserNetInfoState.fetched;
      return;
    } catch (e) {
      currentUserNetInfoStatus.value = CurrentUserNetInfoState.error;
    }
  }

  String _getPostStringBody(Map<String, dynamic> toPost) {
    String toPostStr = "";
    for (var i in toPost.keys) {
      toPostStr +=
          "${Uri.encodeQueryComponent(i)}=${Uri.encodeQueryComponent(toPost[i]!)}";
      if (i != toPost.keys.last) {
        toPostStr += "&";
      }
    }
    return toPostStr;
  }

  Future<void> _getNetworkUsage() async {
    // Return data
    try {
      final page = await _dio.get("/home").then((page) => page.data);

      List<(String, String, String)> ipList = [];
      String used = "";
      String rest = "";
      String charged = "";
      parse(page).getElementsByTagName("tr").forEach((value) {
        var tdList = value.getElementsByTagName("td");
        if (tdList.length == 7) {
          String usedT = tdList[2].innerHtml;
          if (usedT.isNotEmpty) {
            ipList.add((tdList[1].innerHtml, tdList[3].innerHtml, usedT));
          }
        } else if (tdList.length == 4) {
          used = tdList[1].innerHtml;
          rest = tdList[2].innerHtml;
          charged = tdList[3].innerHtml;
        }
      });
      networkInfo.value = NetworkUsage(
        ipList: ipList,
        used: used,
        rest: rest,
        charged: charged,
      );
      isError.value = "";
      schoolNetStatus.value = SessionState.fetched;
    } catch (e) {
      isError.value = "homepage.school_net.failed";
      schoolNetStatus.value = SessionState.error;
    }
  }

  Future<void> getNetworkUsage({
    required Future<String> Function(List<int>)? captchaFunction,
  }) async {
    schoolNetStatus.value = SessionState.fetching;
    isError.value = "";
    // Get username and password
    String password = prefs.getString(prefs.Preference.schoolNetQueryPassword);
    if (password.isEmpty) {
      isError.value = "school_net.empty_password";
      schoolNetStatus.value = SessionState.error;
      return;
    }
    String username = prefs.getString(prefs.Preference.idsAccount);
    // Check whether fetch directly
    var page = await _dio.get("/home");
    if (!page.isRedirect) {
      _getNetworkUsage();
      return;
    }
    //clearCookieJarSpecific("https://zfw.xidian.edu.cn");
    // Get login page
    page = await _dio.get("/login");
    // Get csrf and key
    List<Element> inputs = parse(
      page.data.toString(),
    ).getElementsByTagName("input");
    String csrf = "";
    String key = "";
    for (var i in inputs) {
      if (i.attributes["name"]?.contains("csrf") ?? false) {
        csrf = i.attributes["value"] ?? "";
      }
      if (i.attributes["id"]?.contains("public") ?? false) {
        key = i.attributes["value"] ?? "";
      }
      if (csrf.isNotEmpty && key.isNotEmpty) break;
    }
    if (csrf.isEmpty || key.isEmpty) {
      isError.value = "school_net.not_initalized";
      schoolNetStatus.value = SessionState.error;
      return;
    }

    String lastErrorMessage = "";
    for (int retry = 10; retry > 0; retry--) {
      // Clear it everytime new try.
      lastErrorMessage = "";

      // Refresh captcha
      await _dio.get(
        'https://zfw.xidian.edu.cn/site/captcha',
        queryParameters: {
          'refresh': 1,
          '_': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Get verifycode
      var picture = await _dio
          .get(
            "https://zfw.xidian.edu.cn/site/captcha",
            options: Options(responseType: ResponseType.bytes),
          )
          .then((data) => data.data);
      String failedmsg = "school_net.captcha_failed";
      String? verifycode = retry == 1
          ? captchaFunction != null
                ? await captchaFunction(picture)
                : failedmsg // The last try
          : await DigitCaptchaClientProvider.infer(
              DigitCaptchaType.zfw,
              picture,
            );

      // If failed too much time, set error state.
      if (verifycode == failedmsg) {
        isError.value = failedmsg;
        schoolNetStatus.value = SessionState.error;
        return;
      }
      if (verifycode == null) {
        log.info('[SchoolnetSession] Captcha is impossible to be inferred.');
        retry++; // Do not count this try
        continue;
      }

      log.info("[SchoolnetSession] verifycode is $verifycode");

      // Encrypt the password
      var rsaKey = RSAKeyParser().parse(key);
      String encryptedPassword = Encrypter(
        RSA(publicKey: RSAPublicKey(rsaKey.modulus!, rsaKey.exponent!)),
      ).encrypt(password).base64;

      // Pre-login post
      page = await _dio.post(
        "/site/validate-user",
        data: _getPostStringBody({
          "LoginForm[username]": username, //prefs.getString("idsAccount"),
          "LoginForm[password]": encryptedPassword,
          "LoginForm[verifyCode]": verifycode,
        }),
        options: Options(
          headers: {
            "X-CSRF-Token": csrf,
            "Accept": "*/*",
            "Accept-Encoding": "gzip, deflate, br, zstd",
            "X-Requested-With": "XMLHttpRequest",
          },
        ),
      );

      // Check success or not?
      if (!jsonDecode(page.data)["success"]) {
        lastErrorMessage = jsonDecode(page.data)["message"] ?? "unknown";
        log.info(
          "[SchoolNetSession] Attempt ${11 - retry} "
          "failed: $lastErrorMessage",
        );

        // No need to retry if the error is about username or password
        if (lastErrorMessage.contains("用户名") ||
            lastErrorMessage.contains("密码")) {
          lastErrorMessage = "school_net.wrong_password";
          break;
        }

        continue;
      }

      // Login post
      page = await _dio.post(
        "/",
        data: _getPostStringBody({
          "_csrf-8800": csrf,
          "LoginForm[username]": username, //prefs.getString("idsAccount"),
          "LoginForm[password]": encryptedPassword,
          "LoginForm[smsCode]": "",
          "LoginForm[verifyCode]": verifycode,
        }),
        options: Options(
          headers: {
            "X-CSRF-Token": csrf,
            "Accept": "*/*",
            "Accept-Encoding": "gzip, deflate, br, zstd",
            "X-Requested-With": "XMLHttpRequest",
          },
        ),
      );

      await _getNetworkUsage();
      if (lastErrorMessage.isEmpty) {
        return;
      }
    }

    isError.value = lastErrorMessage;
    schoolNetStatus.value = SessionState.error;
    return;
  }
}
