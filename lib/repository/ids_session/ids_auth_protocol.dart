// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

const _idsOrigin = 'https://ids.xidian.edu.cn';

bool isIDSReAuthLocation(String location, {Uri? baseUri}) {
  final uri = (baseUri ?? Uri.parse(_idsOrigin)).resolve(location);
  return uri.scheme == 'https' &&
      uri.host == 'ids.xidian.edu.cn' &&
      uri.path == '/authserver/reAuthCheck/reAuthLoginView.do';
}

enum IDSReAuthSubmitStatus { success, failed, unauthorized }

class IDSReAuthSubmitResult {
  const IDSReAuthSubmitResult({required this.status, required this.message});

  final IDSReAuthSubmitStatus status;
  final String message;
}

IDSReAuthSubmitResult parseIDSReAuthSubmit(Map<dynamic, dynamic> json) {
  final code = json['code']?.toString();
  final message = json['msg']?.toString() ?? '二次认证失败';
  final status = switch (code) {
    'reAuth_success' => IDSReAuthSubmitStatus.success,
    'reAuth_failed' => IDSReAuthSubmitStatus.failed,
    'reAuth_unauthorized' => IDSReAuthSubmitStatus.unauthorized,
    _ => throw const IDSProtocolException('统一认证返回了未知的二次认证状态'),
  };
  return IDSReAuthSubmitResult(status: status, message: message);
}

class IDSSmsDelivery {
  const IDSSmsDelivery({
    required this.message,
    required this.maskedMobile,
    required this.retryAfter,
    required this.wasAlreadySent,
  });

  final String message;
  final String? maskedMobile;
  final Duration retryAfter;
  final bool wasAlreadySent;
}

IDSSmsDelivery parseIDSSmsDelivery(Map<dynamic, dynamic> json) {
  final result = json['res']?.toString();
  if (result != 'success' && result != 'code_time_fail') {
    throw IDSProtocolException(
      json['returnMessage']?.toString() ?? '短信验证码发送失败',
    );
  }

  final rawSeconds = int.tryParse(json['codeTime']?.toString() ?? '');
  final seconds = rawSeconds == null || rawSeconds < 0 ? 0 : rawSeconds;
  final mobile = json['mobile']?.toString();
  return IDSSmsDelivery(
    message: json['returnMessage']?.toString() ?? '验证码已发送',
    maskedMobile: mobile == null || mobile.isEmpty
        ? null
        : maskIDSPhoneNumber(mobile),
    retryAfter: Duration(seconds: seconds),
    wasAlreadySent: result == 'code_time_fail',
  );
}

String maskIDSPhoneNumber(String value) {
  if (value.length < 7) return '****';
  return '${value.substring(0, 3)}****${value.substring(value.length - 4)}';
}

class IDSProtocolException implements Exception {
  const IDSProtocolException(this.message);

  final String message;

  @override
  String toString() => message;
}
