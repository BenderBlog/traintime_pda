// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

typedef WearIDSReAuthHandler = Future<Uri> Function(WearIDSReAuthClient client);

class WearIDSReAuthClient {
  WearIDSReAuthClient({
    required Dio dio,
    required this.challengeUri,
    required this.username,
    required this.service,
  }) : _dio = dio;

  final Dio _dio;
  final Uri challengeUri;
  final String username;
  final String service;

  String? recipientDescription;
  bool _prepared = false;

  String get _isMultifactor =>
      challengeUri.queryParameters['isMultifactor'] ?? 'true';

  Future<void> prepare() async {
    if (_prepared) return;
    final challengeResponse = await _dio.getUri(challengeUri);
    if (challengeResponse.statusCode != HttpStatus.ok) {
      throw const WearIDSReAuthExpiredException('二次认证已失效，请重新登录');
    }
    final response = await _dio.post(
      'https://ids.xidian.edu.cn/authserver/reAuthCheck/changeReAuthType.do',
      data: {
        'isMultifactor': _isMultifactor,
        'reAuthType': '3',
        'service': service,
      },
    );
    final json = _responseJson(response.data);
    if (json['code']?.toString() != '1') {
      throw WearIDSProtocolException(
        json['message']?.toString() ?? '无法切换到短信二次认证',
      );
    }
    final data = json['data'];
    if (data is Map) {
      recipientDescription = data['reAuthUserNameInput']?.toString();
    }
    _prepared = true;
  }

  Future<WearIDSSmsDelivery> sendSms() async {
    await prepare();
    final response = await _dio.post(
      'https://ids.xidian.edu.cn/authserver/dynamicCode/'
      'getDynamicCodeByReauth.do',
      data: {'userName': username, 'authCodeTypeName': 'reAuthDynamicCodeType'},
    );
    final json = _responseJson(response.data);
    final result = json['res']?.toString();
    if (result != 'success' && result != 'code_time_fail') {
      throw WearIDSProtocolException(
        json['returnMessage']?.toString() ?? '短信验证码发送失败',
      );
    }
    final rawSeconds = int.tryParse(json['codeTime']?.toString() ?? '');
    final seconds = rawSeconds == null || rawSeconds < 0 ? 0 : rawSeconds;
    final mobile = json['mobile']?.toString();
    return WearIDSSmsDelivery(
      message: json['returnMessage']?.toString() ?? '验证码已发送',
      recipient: mobile == null || mobile.isEmpty
          ? recipientDescription
          : _maskPhoneNumber(mobile),
      retryAfter: Duration(seconds: seconds),
    );
  }

  Future<Uri> submitSms({
    required String code,
    required bool trustDevice,
  }) async {
    await prepare();
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw const WearIDSReAuthCodeRejectedException('请输入短信验证码');
    }
    final response = await _dio.post(
      'https://ids.xidian.edu.cn/authserver/reAuthCheck/reAuthSubmit.do',
      data: {
        'service': service,
        'reAuthType': '3',
        'isMultifactor': _isMultifactor,
        'password': '',
        'dynamicCode': normalizedCode,
        'uuid': '',
        'answer1': '',
        'answer2': '',
        'otpCode': '',
        'skipTmpReAuth': trustDevice.toString(),
      },
    );
    final json = _responseJson(response.data);
    final result = json['code']?.toString();
    if (result == 'reAuth_failed') {
      throw WearIDSReAuthCodeRejectedException(
        json['msg']?.toString() ?? '验证码错误',
      );
    }
    if (result == 'reAuth_unauthorized') {
      throw WearIDSReAuthExpiredException(json['msg']?.toString() ?? '二次认证已失效');
    }
    if (result != 'reAuth_success') {
      throw const WearIDSProtocolException('统一认证返回了未知的二次认证状态');
    }

    final loginResponse = await _dio.get(
      'https://ids.xidian.edu.cn/authserver/login',
      queryParameters: {'service': service},
    );
    final location = loginResponse.headers.value(HttpHeaders.locationHeader);
    if ((loginResponse.statusCode != HttpStatus.movedPermanently &&
            loginResponse.statusCode != HttpStatus.found) ||
        location == null) {
      throw const WearIDSProtocolException('二次认证成功，但没有收到业务系统登录票据');
    }
    final uri = Uri.parse('https://ids.xidian.edu.cn').resolve(location);
    if (uri.host == 'ids.xidian.edu.cn' &&
        uri.path == '/authserver/reAuthCheck/reAuthLoginView.do') {
      throw const WearIDSReAuthExpiredException('二次认证未完成，请重新登录');
    }
    return uri;
  }
}

class WearIDSSmsDelivery {
  const WearIDSSmsDelivery({
    required this.message,
    required this.recipient,
    required this.retryAfter,
  });

  final String message;
  final String? recipient;
  final Duration retryAfter;
}

Future<Uri> showWearIDSReAuthPage(
  BuildContext context,
  WearIDSReAuthClient client,
) async {
  final result = await Navigator.of(context).push<Uri>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _WearIDSReAuthPage(client: client),
    ),
  );
  if (result == null) throw const WearIDSReAuthCancelledException();
  return result;
}

class _WearIDSReAuthPage extends StatefulWidget {
  const _WearIDSReAuthPage({required this.client});

  final WearIDSReAuthClient client;

  @override
  State<_WearIDSReAuthPage> createState() => _WearIDSReAuthPageState();
}

class _WearIDSReAuthPageState extends State<_WearIDSReAuthPage> {
  final _codeController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _trustDevice = true;
  bool _sending = false;
  bool _submitting = false;
  String? _notice;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendCode());
  }

  Future<void> _sendCode() async {
    if (_sending || _secondsRemaining > 0) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final delivery = await widget.client.sendSms();
      if (!mounted) return;
      setState(() {
        _notice = delivery.recipient == null
            ? delivery.message
            : '${delivery.message}\n${delivery.recipient}';
      });
      _startCountdown(delivery.retryAfter.inSeconds);
    } on DioException {
      if (mounted) setState(() => _error = '网络连接失败');
    } on WearIDSReAuthExpiredException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on WearIDSProtocolException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsRemaining = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting || _codeController.text.trim().isEmpty) {
      if (_codeController.text.trim().isEmpty) {
        setState(() => _error = '请输入短信验证码');
      }
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final uri = await widget.client.submitSms(
        code: _codeController.text,
        trustDevice: _trustDevice,
      );
      if (mounted) Navigator.of(context).pop(uri);
    } on WearIDSReAuthCodeRejectedException catch (error) {
      _codeController.clear();
      if (mounted) setState(() => _error = error.message);
    } on DioException {
      if (mounted) setState(() => _error = '网络连接失败');
    } on WearIDSReAuthExpiredException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on WearIDSProtocolException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = _sending || _submitting;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(34, 30, 34, 40),
          children: [
            Text(
              '短信认证',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _notice ?? '正在准备验证码…',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              enabled: !busy,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              textAlign: TextAlign.center,
              maxLength: 8,
              decoration: const InputDecoration(
                hintText: '验证码',
                counterText: '',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: busy || _secondsRemaining > 0 ? null : _sendCode,
              child: Text(
                _secondsRemaining > 0 ? '${_secondsRemaining}s 后重发' : '发送验证码',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _trustDevice,
              onChanged: busy
                  ? null
                  : (value) => setState(() => _trustDevice = value),
              title: const Text('信任此手表'),
            ),
            FilledButton(
              onPressed: busy ? null : _submit,
              child: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('确认'),
            ),
            TextButton(
              onPressed: busy ? null : () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        ),
      ),
    );
  }
}

Map<dynamic, dynamic> _responseJson(dynamic data) {
  if (data is Map) return data;
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) return decoded;
    } on FormatException {
      // Fall through to the protocol exception below.
    }
  }
  throw const WearIDSProtocolException('统一认证返回了非 JSON 响应');
}

String _maskPhoneNumber(String value) {
  if (value.length < 7) return '****';
  return '${value.substring(0, 3)}****${value.substring(value.length - 4)}';
}

class WearIDSProtocolException implements Exception {
  const WearIDSProtocolException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WearIDSReAuthCodeRejectedException implements Exception {
  const WearIDSReAuthCodeRejectedException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WearIDSReAuthExpiredException implements Exception {
  const WearIDSReAuthExpiredException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WearIDSReAuthCancelledException implements Exception {
  const WearIDSReAuthCancelledException();
  @override
  String toString() => '已取消短信认证';
}
