// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// IDS (统一认证服务) login class.
// Thanks xidian-script and libxdauth!

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:encrypter_plus/encrypter_plus.dart' as encrypt;
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/repository/ids_session/slider_captcha_client.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/ids_session/ids_auth_protocol.dart';
import 'package:watermeter/repository/ids_session/ids_fingerprint.dart';
import 'package:watermeter/repository/ids_session/ids_reauth_client.dart';

enum IDSLoginState {
  none,
  requesting,
  success,
  fail,
  passwordWrong,
  cancelled,

  /// Indicate that the user will login via LoginWindow
  manual,
}

IDSLoginState loginState = IDSLoginState.none;

bool get offline =>
    loginState != IDSLoginState.success && loginState != IDSLoginState.manual;

class IDSSession {
  static final _idslock = Lock();
  static const maxAuthRedirects = 30;

  Dio get dio {
    log.info('[IDSSession][OfflineCheck] Offline status: $offline');
    if (offline) {
      throw DioException.requestCancelled(
        reason: 'Offline mode, all IDS functions are unavailable.',
        requestOptions: RequestOptions(path: ''),
      );
    }
    return NetworkClients.idsDio;
  }

  /// Authentication and SSO requests bypass the business offline guard while
  /// still using the one process-wide IDS client and cookie store.
  Dio get dioNoOfflineCheck => NetworkClients.idsDio;

  /// Get base64 encoded data. Which is aes encrypted [toEnc] encoded string using [key].
  /// Padding part is libxduauth's idea.
  String aesEncrypt(String toEnc, String key) {
    dynamic k = encrypt.Key.fromUtf8(key);
    var crypt = encrypt.AES(k, mode: encrypt.AESMode.cbc, padding: null);

    /// Start padding
    int blockSize = 16;
    List<int> dataToPad = [];
    dataToPad.addAll(
      utf8.encode(
        "xidianscriptsxduxidianscriptsxduxidianscriptsxduxidianscriptsxdu$toEnc",
      ),
    );
    int paddingLength = blockSize - dataToPad.length % blockSize;
    for (var i = 0; i < paddingLength; ++i) {
      dataToPad.add(paddingLength);
    }
    String readyToEnc = utf8.decode(dataToPad);

    /// Start encrypt.
    return encrypt.Encrypter(
      crypt,
    ).encrypt(readyToEnc, iv: encrypt.IV.fromUtf8('xidianscriptsxdu')).base64;
  }

  static const _header = [
    // "username",
    // "password",
    // "captcha",
    //"_eventId",
    "lt",
    //"cllt",
    //"dllt",
    "execution",
  ];

  String _parsePasswordWrongMsg(String html) {
    var form = parse(html).getElementById("showErrorTip");
    var msg = form?.text ?? "登录遇到问题";

    // Simplify the error message because there is no '找回密码' button here XD.
    // "用户名或密码有误，用户名为工号/学号，如果确认用户名无误，请点‘找回密码’自助重置密码。"
    if (msg.contains(RegExp(r"(用户名|密码).*误", unicode: true, dotAll: true))) {
      msg = "用户名或密码有误";
    }
    return msg;
  }

  Future<String> checkAndLogin({
    required String target,
    required Future<void> Function(String) sliderCaptcha,
    IDSReAuthHandler? reAuthHandler,
  }) async {
    return await _idslock.synchronized(() async {
      try {
        log.info('[IDSSession][checkAndLogin] Checking IDS session.');
        var response = await dioNoOfflineCheck.get(
          'https://ids.xidian.edu.cn/authserver/login',
          queryParameters: {'service': target},
        );
        if (_isRedirect(response)) {
          return _completeRedirect(
            response: response,
            target: target,
            username: preference.getString(preference.Preference.idsAccount),
            reAuthHandler: reAuthHandler,
          );
        }

        final continued = await _submitContinueForm(response.data);
        if (continued != null && _isRedirect(continued)) {
          return _completeRedirect(
            response: continued,
            target: target,
            username: preference.getString(preference.Preference.idsAccount),
            reAuthHandler: reAuthHandler,
          );
        }

        return login(
          username: preference.getString(preference.Preference.idsAccount),
          password: preference.getString(preference.Preference.idsPassword),
          sliderCaptcha: sliderCaptcha,
          target: target,
          reAuthHandler: reAuthHandler,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == HttpStatus.unauthorized) {
          throw PasswordWrongException(
            msg: _parsePasswordWrongMsg(e.response?.data?.toString() ?? ''),
          );
        }
        rethrow;
      }
    });
  }

  Future<String> login({
    required String username,
    required String password,
    required Future<void> Function(String) sliderCaptcha,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
    String? target,
    IDSReAuthHandler? reAuthHandler,
  }) async {
    /// Get the login webpage.
    if (onResponse != null) {
      onResponse(10, "login_process.ready_page");
      log.info(
        "[IDSSession][login] "
        "Ready to get the login webpage.",
      );
    }
    late final Response<dynamic> initialResponse;
    try {
      initialResponse = await dioNoOfflineCheck.get(
        'https://ids.xidian.edu.cn/authserver/login',
        queryParameters: target != null ? {'service': target} : null,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == HttpStatus.unauthorized) {
        throw PasswordWrongException(
          msg: _parsePasswordWrongMsg(error.response?.data?.toString() ?? ''),
        );
      }
      rethrow;
    }
    if (_isRedirect(initialResponse)) {
      return _completeRedirect(
        response: initialResponse,
        target: target,
        username: username,
        reAuthHandler: reAuthHandler,
        onResponse: onResponse,
      );
    }

    await _registerBrowserFingerprint();
    final response = initialResponse.data?.toString() ?? '';

    /// Start getting data from webpage.
    var page = parse(response);
    var form = page.getElementsByTagName("input")
      ..removeWhere((element) => element.attributes["type"] != "hidden");

    /// Check whether it need CAPTCHA or not:-P
    /// Used in two captcha.
    String cookieStr = "";
    var cookie = await NetworkCookieJars.ids.loadForRequest(
      Uri.parse("https://ids.xidian.edu.cn/authserver"),
    );
    for (var i in cookie) {
      cookieStr += "${i.name}=${i.value}; ";
    }

    /// Get AES encrypt key. There must be.
    if (onResponse != null) {
      onResponse(30, "login_process.get_encrypt");
    }
    String keys = form
        .firstWhere((element) => element.id == "pwdEncryptSalt")
        .attributes["value"]!;

    /// Prepare for login.
    if (onResponse != null) {
      onResponse(40, "login_process.ready_login");
    }
    Map<String, dynamic> head = {
      'username': username,
      'password': aesEncrypt(password, keys),
      'rememberMe': 'true',
      'cllt': 'userNameLogin',
      'dllt': 'generalLogin',
      '_eventId': 'submit',
    };

    for (var i in _header) {
      head[i] = form
          .firstWhere(
            (element) => element.attributes["name"] == i || element.id == i,
          )
          .attributes["value"]!;
    }

    if (onResponse != null) {
      onResponse(45, "login_process.slider");
    }

    await dioNoOfflineCheck.get(
      "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
    );

    try {
      await sliderCaptcha(cookieStr);
    } on CaptchaSolveFailedException {
      throw const LoginFailedException(msg: "验证码校验失败");
    }

    /// Post login request.
    if (onResponse != null) {
      onResponse(50, "login_process.ready_login");
    }
    try {
      var data = await dioNoOfflineCheck.post(
        "https://ids.xidian.edu.cn/authserver/login",
        queryParameters: target != null ? {'service': target} : null,
        data: head,
        options: Options(
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
      );
      if (_isRedirect(data)) {
        return _completeRedirect(
          response: data,
          target: target,
          username: username,
          reAuthHandler: reAuthHandler,
          onResponse: onResponse,
        );
      } else {
        /// Check whether need continue.
        log.info(
          "[IDSSession][login] "
          "data: ${(data.data as String).length}.",
        );

        var page = parse(data.data ?? "");
        var form = page.getElementsByTagName("form")
          ..removeWhere((element) => element.id != "continue");
        if (form.isNotEmpty) {
          var inputSearch = form[0].getElementsByTagName("input");
          Map<String, String> toPostAgain = {};
          for (var i in inputSearch) {
            toPostAgain[i.attributes["name"]!] = i.attributes["value"]!;
          }
          var data = await dioNoOfflineCheck.post(
            "https://ids.xidian.edu.cn/authserver/login",
            data: toPostAgain,
            options: Options(
              validateStatus: (status) =>
                  status != null && status >= 200 && status < 400,
            ),
          );
          if (_isRedirect(data)) {
            return _completeRedirect(
              response: data,
              target: target,
              username: username,
              reAuthHandler: reAuthHandler,
              onResponse: onResponse,
            );
          }
        }
        throw LoginFailedException(msg: "登录失败，响应状态码：${data.statusCode}。");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw PasswordWrongException(
          msg: _parsePasswordWrongMsg(e.response!.data),
        );
      } else {
        rethrow;
      }
    }
  }

  bool _isRedirect(Response<dynamic> response) =>
      response.statusCode == HttpStatus.movedPermanently ||
      response.statusCode == HttpStatus.found;

  Future<Response<dynamic>?> _submitContinueForm(dynamic responseData) async {
    final page = parse(responseData?.toString() ?? '');
    final form = page.getElementById('continue');
    if (form == null || form.localName != 'form') return null;

    final fields = <String, String>{};
    for (final input in form.getElementsByTagName('input')) {
      final name = input.attributes['name'];
      final value = input.attributes['value'];
      if (name != null && value != null) fields[name] = value;
    }
    return dioNoOfflineCheck.post(
      'https://ids.xidian.edu.cn/authserver/login',
      data: fields,
    );
  }

  Future<void> _registerBrowserFingerprint() async {
    final fingerprint = await getOrCreateIDSBrowserFingerprint();
    await dioNoOfflineCheck.get(
      'https://ids.xidian.edu.cn/authserver/bfp/info',
      queryParameters: {
        'bfp': fingerprint,
        '_': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  Future<String> _completeRedirect({
    required Response<dynamic> response,
    required String? target,
    required String username,
    required IDSReAuthHandler? reAuthHandler,
    void Function(int, String)? onResponse,
  }) async {
    final location = response.headers.value(HttpHeaders.locationHeader);
    if (location == null) {
      throw const IDSProtocolException('统一认证跳转响应缺少 Location');
    }
    final uri = response.realUri.resolve(location);
    final resolved = await resolveIDSReAuthIfNeeded(
      uri,
      service: target,
      username: username,
      reAuthHandler: reAuthHandler,
      onResponse: onResponse,
    );
    onResponse?.call(80, 'login_process.after_process');
    return resolved.toString();
  }

  Future<Uri> resolveIDSReAuthIfNeeded(
    Uri uri, {
    String? service,
    String? username,
    IDSReAuthHandler? reAuthHandler,
    void Function(int, String)? onResponse,
  }) async {
    if (!isIDSReAuthLocation(uri.toString())) return uri;

    final previousLoginState = loginState;
    loginState = IDSLoginState.requesting;
    final handler = reAuthHandler ?? activeIDSReAuthHandler;
    if (handler == null) {
      loginState = IDSLoginState.fail;
      throw const IDSReAuthRequiredException();
    }

    try {
      onResponse?.call(55, 'login_process.second_factor');
      final resumedUri = await handler(
        IDSReAuthClient(
          dio: dioNoOfflineCheck,
          challengeUri: uri,
          username:
              username ??
              preference.getString(preference.Preference.idsAccount),
          service: uri.queryParameters['service'] ?? service,
          registerBrowserFingerprint: _registerBrowserFingerprint,
        ),
      );
      loginState = switch (previousLoginState) {
        IDSLoginState.success => IDSLoginState.success,
        IDSLoginState.manual => IDSLoginState.manual,
        _ => IDSLoginState.requesting,
      };
      return resumedUri;
    } on IDSReAuthCancelledException {
      await NetworkCookieJars.ids.deleteAll();
      loginState = IDSLoginState.cancelled;
      rethrow;
    } on IDSReAuthExpiredException {
      await NetworkCookieJars.ids.deleteAll();
      loginState = IDSLoginState.fail;
      rethrow;
    }
  }

  Future<Response<dynamic>> followIDSRedirects({
    required String initialLocation,
    Dio? client,
    String? service,
    String? username,
    IDSReAuthHandler? reAuthHandler,
  }) async {
    final requestClient = client ?? dioNoOfflineCheck;
    var currentUri = Uri.parse(
      'https://ids.xidian.edu.cn',
    ).resolve(initialLocation);
    var currentService = service;
    var redirectCount = 0;

    while (true) {
      currentService = _idsLoginService(currentUri) ?? currentService;
      currentUri = await resolveIDSReAuthIfNeeded(
        currentUri,
        service: currentService,
        username: username,
        reAuthHandler: reAuthHandler,
      );
      currentService = _idsLoginService(currentUri) ?? currentService;

      final response = await requestClient.getUri(currentUri);
      final location = response.headers.value(HttpHeaders.locationHeader);
      if (location == null) return response;

      redirectCount++;
      final sourceUri = response.realUri;
      final nextUri = sourceUri.resolve(location);
      log.info(
        '[IDSSession][followIDSRedirects] Redirect #$redirectCount: '
        '${_redirectLogUri(sourceUri)} -> ${_redirectLogUri(nextUri)}',
      );
      if (redirectCount > maxAuthRedirects) {
        throw const LoginFailedException(msg: '统一认证跳转次数超过 30 次');
      }
      currentUri = nextUri;
    }
  }

  String _redirectLogUri(Uri uri) {
    final queryKeys = uri.queryParametersAll.keys.toList()..sort();
    final baseUri = _redirectLogBaseUri(uri);
    if (queryKeys.isEmpty) return baseUri;

    final queryLabels = queryKeys.map((key) {
      if (key != 'service') return key;
      final values = uri.queryParametersAll[key];
      final serviceUri = values == null || values.isEmpty
          ? null
          : Uri.tryParse(values.first);
      if (serviceUri == null ||
          !serviceUri.hasScheme ||
          serviceUri.host.isEmpty) {
        return key;
      }
      return '$key=${_redirectLogBaseUri(serviceUri)}';
    });
    return '$baseUri?${queryLabels.join('&')}';
  }

  String _redirectLogBaseUri(Uri uri) => Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  ).toString();

  String? _idsLoginService(Uri uri) {
    if (uri.host != 'ids.xidian.edu.cn' || uri.path != '/authserver/login') {
      return null;
    }
    final service = uri.queryParameters['service'];
    return service == null || service.isEmpty ? null : service;
  }

  Future<bool> checkWhetherPostgraduate({
    IDSReAuthHandler? reAuthHandler,
  }) async {
    String location = await checkAndLogin(
      target:
          "https://yjspt.xidian.edu.cn/gsapp"
          "/sys/yjsemaphome/portal/index.do",
      sliderCaptcha: (cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(),
    );
    await followIDSRedirects(
      initialLocation: location,
      reAuthHandler: reAuthHandler,
    );

    bool toReturn = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp"
          "/sys/yjsemaphome/modules/pubWork/getCanVisitAppList.do",
        )
        .then((value) => value.data["res"] != null);

    preference.setBool(preference.Preference.role, toReturn);

    return toReturn;
  }
}

class NeedCaptchaException implements Exception {}

class PasswordWrongException implements Exception {
  final String msg;
  const PasswordWrongException({required this.msg});
  @override
  String toString() => msg;
}

class LoginFailedException implements Exception {
  final String msg;
  const LoginFailedException({required this.msg});
  @override
  String toString() => msg;
}
