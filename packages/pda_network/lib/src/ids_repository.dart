// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:pda_repository/pda_repository.dart';

import 'ids_http_session.dart';
import 'utils/ids_encryption.dart';
import 'utils/ids_redirects.dart';
import 'utils/ids_slider_solver.dart';

final class IdsRepository implements IdsNetworkRepository {
  IdsRepository(IdsSessionStore store, {Dio Function()? dioFactory})
    : _sessionStore = store,
      session = IdsHttpSession(store, dioFactory: dioFactory);

  static final Uri _ids = Uri.parse('https://ids.xidian.edu.cn');
  static const _maxRedirects = 30;
  final IdsSessionStore _sessionStore;
  final IdsHttpSession session;
  Future<Dio>? _client;
  int _generation = 0;

  @override
  Future<void> clear() async {
    ++_generation;
    _client = null;
    await session.clear();
  }

  void close() {
    ++_generation;
    session.close();
  }

  @override
  Future<void> login(
    String username,
    String password, {
    IdsInteraction interaction = const IdsInteraction(),
  }) => _login(_generation, username, password, interaction);

  @override
  Future<void> authorize(
    Uri service, {
    IdsInteraction interaction = const IdsInteraction(),
  }) => _authorize(_generation, service, interaction);

  Future<void> _login(
    int generation,
    String username,
    String password,
    IdsInteraction interaction,
  ) async {
    await session.clear();
    _check(generation);
    _client = null;
    final loginUri = _ids.replace(path: '/authserver/login');
    var response = await _request(generation, loginUri);
    if (_redirect(response)) {
      await _follow(generation, response, null, interaction);
      return;
    }
    if (response.statusCode == 401) {
      throw const IdsCredentialsRejected('用户名或密码有误');
    }
    final form = html
        .parse(response.data?.toString() ?? '')
        .getElementById('pwdFromId');
    if (form == null || form.localName != 'form') {
      throw const FormatException('统一认证页面缺少密码登录表单');
    }
    final fields = <String, String>{};
    for (final name in ['pwdEncryptSalt', 'lt', 'execution']) {
      final matches = form
          .querySelectorAll('input[type="hidden"]')
          .where(
            (input) => input.id == name || input.attributes['name'] == name,
          )
          .toList();
      if (matches.length != 1) {
        throw FormatException('统一认证表单字段无效: $name');
      }
      final value = matches.single.attributes['value'];
      if (value == null || (name != 'lt' && value.isEmpty)) {
        throw FormatException('统一认证表单字段无效: $name');
      }
      fields[name] = value;
    }
    final salt = fields.remove('pwdEncryptSalt')!;
    if (![16, 24, 32].contains(utf8.encode(salt).length)) {
      throw const FormatException('统一认证加密参数无效');
    }
    await _request(
      generation,
      _ids.replace(
        path: '/authserver/bfp/info',
        queryParameters: {
          'bfp': await _browserFingerprint(generation),
          '_': '${DateTime.now().millisecondsSinceEpoch}',
        },
      ),
    );
    await _solveSlider(generation, interaction);
    response = await _request(
      generation,
      loginUri,
      method: 'POST',
      data: {
        'username': username,
        'password': encryptIdsPassword(password, salt),
        'rememberMe': 'true',
        'cllt': 'userNameLogin',
        'dllt': 'generalLogin',
        '_eventId': 'submit',
        ...fields,
      },
    );
    if (response.statusCode == 401) {
      throw const IdsCredentialsRejected('用户名或密码有误');
    }
    if (!_redirect(response)) {
      final continued = await _continue(generation, response);
      if (continued == null || !_redirect(continued)) {
        throw const IdsLoginException('统一认证未完成登录');
      }
      response = continued;
    }
    await _follow(generation, response, null, interaction);
  }

  Future<void> _authorize(
    int generation,
    Uri service,
    IdsInteraction interaction,
  ) async {
    validateIdsService(service);
    final loginUri = _ids.replace(
      path: '/authserver/login',
      queryParameters: {'service': service.toString()},
    );
    var response = await _request(generation, loginUri);
    if (_redirect(response)) {
      await _follow(generation, response, service, interaction);
      return;
    }
    if (response.statusCode == 401 || _isLoginPage(response)) {
      throw const IdsSessionExpired('IDS 会话已失效');
    }
    final continued = await _continue(generation, response);
    if (continued != null) {
      response = continued;
      if (_redirect(response)) {
        await _follow(generation, response, service, interaction);
        return;
      }
      if (response.statusCode == 401 || _isLoginPage(response)) {
        throw const IdsSessionExpired('IDS 会话已失效');
      }
    }
    throw const IdsLoginException('IDS 未返回目标服务票据');
  }

  Future<Response<dynamic>?> _continue(
    int generation,
    Response<dynamic> response,
  ) async {
    final form = html
        .parse(response.data?.toString() ?? '')
        .getElementById('continue');
    if (form == null || form.localName != 'form') return null;
    final fields = <String, String>{};
    for (final input in form.getElementsByTagName('input')) {
      final name = input.attributes['name'];
      final value = input.attributes['value'];
      if (name != null && value != null) fields[name] = value;
    }
    return _request(
      generation,
      _ids.replace(path: '/authserver/login'),
      method: 'POST',
      data: fields,
    );
  }

  Future<void> _solveSlider(int generation, IdsInteraction interaction) async {
    late Uint8List background;
    late Uint8List piece;
    for (var attempt = 0; attempt < 6; attempt++) {
      (background, piece) = await _loadSlider(generation);
      final offset = IdsSliderAlgorithms.solveOffset(background, piece);
      if (offset != null) {
        final base = (offset * 280).round();
        for (final delta in [1, -1, 2, -2, 3, -3, 4]) {
          final move = base + delta;
          if (move < 1 || move > 280) {
            continue;
          }
          if (await _verifySlider(
            generation,
            piece,
            IdsSliderAlgorithms.generateTracks(move),
            delay: true,
          )) {
            return;
          }
        }
      }
    }
    final manual = interaction.solveSlider;
    if (manual == null) throw const IdsLoginException('滑块验证码校验失败');
    var retry = false;
    while (true) {
      final points = await manual(background, piece, retry);
      _check(generation);
      if (points == null) throw const IdsInteractionCancelled('已取消滑块验证');
      if (points.isNotEmpty &&
          await _verifySlider(generation, piece, [
            for (final p in points) TrackPoint(p.x, p.y, p.milliseconds),
          ])) {
        return;
      }
      (background, piece) = await _loadSlider(generation);
      retry = true;
    }
  }

  Future<(Uint8List, Uint8List)> _loadSlider(int generation) async {
    final response = await _request(
      generation,
      _ids.replace(
        path: '/authserver/common/openSliderCaptcha.htl',
        queryParameters: {'_': '${DateTime.now().millisecondsSinceEpoch}'},
      ),
    );
    final data = response.data;
    if (data is! Map ||
        data['bigImage'] is! String ||
        data['smallImage'] is! String) {
      throw const FormatException('滑块验证码格式无效');
    }
    final background = base64Decode(data['bigImage'] as String);
    final piece = base64Decode(data['smallImage'] as String);
    if (piece.length < 16) throw const FormatException('滑块验证码缺少校验密钥');
    return (background, piece);
  }

  Future<bool> _verifySlider(
    int generation,
    Uint8List piece,
    List<TrackPoint> tracks, {
    bool delay = false,
  }) async {
    final payload = jsonEncode({
      'canvasLength': 280,
      'moveLength': tracks.last.a,
      'tracks': tracks,
    });
    final sign = encryptIdsSlider(payload, piece.sublist(piece.length - 16));
    if (delay) {
      await Future<void>.delayed(
        Duration(milliseconds: max(tracks.last.c - 100, 0)),
      );
    }
    final verified = await _request(
      generation,
      _ids.replace(path: '/authserver/common/verifySliderCaptcha.htl'),
      method: 'POST',
      data: 'sign=${Uri.encodeQueryComponent(sign)}',
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        'Origin': 'https://ids.xidian.edu.cn',
      },
    );
    return verified.data is Map &&
        (verified.data as Map)['errorCode']?.toString() == '1';
  }

  Future<void> _follow(
    int generation,
    Response<dynamic> initial,
    Uri? service,
    IdsInteraction interaction,
  ) async {
    var response = initial;
    var ticketConsumed = false;
    for (var hop = 0; hop < _maxRedirects; hop++) {
      final location = response.headers.value(HttpHeaders.locationHeader);
      if (location == null) {
        if (response.statusCode == 200 &&
            service == null &&
            !_isLoginPage(response)) {
          return;
        }
        if (service != null &&
            (response.statusCode == 401 || _isLoginPage(response))) {
          throw const IdsSessionExpired('IDS 会话已失效');
        }
        throw const FormatException('统一认证跳转缺少目标地址');
      }
      final next = response.realUri.resolve(location);
      validateIdsRedirect(next, service, _ids);
      if (service != null && next.host == service.host && !ticketConsumed) {
        validateIdsTicket(next, service);
        ticketConsumed = true;
      }
      if (next.host == _ids.host &&
          next.path == '/authserver/reAuthCheck/reAuthLoginView.do') {
        response = await _secondFactor(generation, next, service, interaction);
        continue;
      }
      response = await _request(generation, next);
      if (!_redirect(response)) {
        if (service != null &&
            (response.statusCode == 401 || _isLoginPage(response))) {
          throw const IdsSessionExpired('IDS 会话已失效');
        }
        if (response.statusCode == 200 &&
            ((service == null && !_isLoginPage(response)) ||
                (ticketConsumed && next.host == service?.host))) {
          return;
        }
        throw const IdsLoginException('统一认证跳转未完成');
      }
    }
    throw const FormatException('统一认证跳转次数超过上限');
  }

  Future<Response<dynamic>> _secondFactor(
    int generation,
    Uri challenge,
    Uri? service,
    IdsInteraction interaction,
  ) async {
    final enter = interaction.enterCode;
    if (enter == null) {
      throw const IdsInteractionRequired('需要二次认证');
    }
    await _request(
      generation,
      _ids.replace(
        path: '/authserver/bfp/info',
        queryParameters: {
          'bfp': await _browserFingerprint(generation),
          '_': '${DateTime.now().millisecondsSinceEpoch}',
        },
      ),
    );
    final page = await _request(generation, challenge);
    final userId = RegExp(r'"reAuthUserId"\s*:\s*"([^"\\]+)"')
        .firstMatch(page.data?.toString() ?? '')
        ?.group(1);
    if (userId == null) {
      throw const FormatException('二次认证页面缺少用户标识');
    }
    IdsCodeType? currentType;
    IdsCodeDelivery? currentDelivery;
    Future<IdsCodeDelivery> sendCode(IdsCodeType type) async {
      final typeValue = type == IdsCodeType.sms ? '3' : '4';
      final codeName = type == IdsCodeType.sms
          ? 'reAuthDynamicCodeType'
          : 'reAuthWChatDynamicCodeType';
      final change = await _request(
        generation,
        _ids.replace(path: '/authserver/reAuthCheck/changeReAuthType.do'),
        method: 'POST',
        data: {
          'isMultifactor': challenge.queryParameters['isMultifactor'] ?? 'true',
          'reAuthType': typeValue,
          'service': service?.toString() ?? '',
        },
      );
      final changed = _jsonMap(change.data);
      if (changed['code']?.toString() != '1') {
        throw const IdsLoginException('无法切换二次认证方式');
      }
      final sent = await _request(
        generation,
        _ids.replace(path: '/authserver/dynamicCode/getDynamicCodeByReauth.do'),
        method: 'POST',
        data: {'userName': userId, 'authCodeTypeName': codeName},
      );
      final delivery = _jsonMap(sent.data);
      if (![
        'success',
        'other_success',
        'wechat_success',
        'code_time_fail',
      ].contains(delivery['res']?.toString())) {
        throw const IdsLoginException('无法发送验证码');
      }
      final rawRecipient = delivery['mobile']?.toString();
      final maskedRecipient = rawRecipient == null || rawRecipient.length < 7
          ? null
          : '${rawRecipient.substring(0, 3)}****${rawRecipient.substring(rawRecipient.length - 4)}';
      final seconds = int.tryParse(delivery['codeTime']?.toString() ?? '') ?? 0;
      currentType = type;
      currentDelivery = IdsCodeDelivery(
        delivery['returnMessage']?.toString(),
        maskedRecipient,
        Duration(seconds: max(seconds, 0)),
        codeType: type,
        sendCode: sendCode,
      );
      return currentDelivery!;
    }

    String? message;
    var codeRejected = false;
    for (var codeAttempt = 0; codeAttempt < 9; codeAttempt++) {
      final entry = await enter(
        IdsCodeDelivery(
          message,
          currentDelivery?.maskedRecipient,
          currentDelivery?.retryAfter ?? Duration.zero,
          sent: currentDelivery != null,
          codeRejected: codeRejected,
          codeType: currentType ?? IdsCodeType.sms,
          sendCode: sendCode,
        ),
      );
      _check(generation);
      if (entry == null) throw const IdsInteractionCancelled('已取消二次认证');
      final (:code, :trustDevice) = entry;
      if (code.trim().isEmpty || currentType == null) {
        continue;
      }
      final typeValue = currentType == IdsCodeType.sms ? '3' : '4';
      final submitted = await _request(
        generation,
        _ids.replace(path: '/authserver/reAuthCheck/reAuthSubmit.do'),
        method: 'POST',
        data: {
          'service': service?.toString() ?? '',
          'reAuthType': typeValue,
          'isMultifactor': challenge.queryParameters['isMultifactor'] ?? 'true',
          'password': '',
          'dynamicCode': code.trim(),
          'uuid': '',
          'answer1': '',
          'answer2': '',
          'otpCode': '',
          'skipTmpReAuth': trustDevice.toString(),
        },
      );
      final result = _jsonMap(submitted.data);
      switch (result['code']?.toString()) {
        case 'reAuth_success':
          return _request(
            generation,
            _ids.replace(
              path: '/authserver/login',
              queryParameters: service == null
                  ? null
                  : {'service': service.toString()},
            ),
          );
        case 'reAuth_failed':
          message = result['msg']?.toString();
          codeRejected = true;
          continue;
        case 'reAuth_unauthorized':
          throw const IdsSessionExpired('二次认证已失效，请重新登录');
        default:
          throw const FormatException('统一认证返回了未知的二次认证状态');
      }
    }
    throw const IdsLoginException('二次认证尝试次数已用尽');
  }

  Future<Response<dynamic>> _request(
    int generation,
    Uri uri, {
    String method = 'GET',
    Object? data,
    String? contentType,
    Map<String, dynamic>? headers,
  }) async {
    _check(generation);
    final client = await (_client ??= session.createClient());
    _check(generation);
    final Response<dynamic> response;
    try {
      response = await client.requestUri<dynamic>(
        uri,
        data: data,
        options: Options(
          method: method,
          headers: headers,
          contentType: contentType,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException {
      _check(generation);
      throw const IdsServiceUnavailable('网络请求失败，请重试');
    }
    _check(generation);
    if ((response.statusCode ?? 0) >= 500) {
      throw const IdsServiceUnavailable('IDS 服务暂时不可用');
    }
    return response;
  }

  void _check(int generation) {
    if (generation != _generation) throw const _IdsStaleOperation();
  }

  bool _redirect(Response<dynamic> response) =>
      response.statusCode == 301 || response.statusCode == 302;

  bool _isLoginPage(Response<dynamic> response) =>
      html.parse(response.data?.toString() ?? '').getElementById('pwdFromId') !=
      null;

  Future<String> _browserFingerprint(int generation) async {
    const key = 'ids.fingerprint';
    final stored = await _sessionStore.read(key);
    _check(generation);
    if (stored != null && RegExp(r'^[0-9A-F]{32}$').hasMatch(stored)) {
      return stored;
    }
    final random = Random.secure();
    final generated = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join().toUpperCase();
    await _sessionStore.write(key, generated);
    _check(generation);
    return generated;
  }

  Map<dynamic, dynamic> _jsonMap(Object? data) {
    if (data is Map) return data;
    if (data is String) {
      final parsed = jsonDecode(data);
      if (parsed is Map) return parsed;
    }
    throw const FormatException('统一认证返回了无效 JSON');
  }
}

final class _IdsStaleOperation implements Exception {
  const _IdsStaleOperation();
}
