// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class RuisiApi {
  static const String _baseUrl = 'https://rs.xidian.edu.cn';
  static const String loginUrl =
      '$_baseUrl/member.php?mod=logging&action=login';

  static const Map<String, String> uploadImageErrors = {
    '-1': '内部服务器错误',
    '0': '上传成功',
    '1': '不支持此类扩展名',
    '2': '服务器限制无法上传那么大的附件',
    '3': '用户组限制无法上传那么大的附件',
    '4': '不支持此类扩展名',
    '5': '文件类型限制无法上传那么大的附件',
    '6': '今日您已无法上传更多的附件',
    '7': '请选择图片文件',
    '8': '附件文件无法保存',
    '9': '没有合法的文件被上传',
    '10': '非法操作',
    '11': '今日您已无法上传那么大的附件',
  };

  late final Dio _dio;

  /// formhash 用于 Discuz 表单提交的 CSRF 校验
  String? formhash;

  /// Talker 日志实例
  final Talker talker;

  /// 持久化 Cookie 存储（退出登录时需要清除）
  late final PersistCookieJar _cookieJar;

  RuisiApi({required String cookiePath, Talker? talker})
    : talker = talker ?? Talker() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {HttpHeaders.userAgentHeader: "myRuisiAsyncLiteHttp/1.0"},
      ),
    );

    // Talker Dio 日志拦截器
    _dio.interceptors.add(
      TalkerDioLogger(
        talker: this.talker,
        settings: const TalkerDioLoggerSettings(
          printRequestData: true,
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      ),
    );

    // Cookie 管理
    _cookieJar = PersistCookieJar(
      storage: FileStorage('$cookiePath/.cookies/'),
    );
    _dio.interceptors.add(CookieManager(_cookieJar));

    // 自动注入 formhash + 重定向日志
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'POST' && formhash != null) {
            if (options.data is FormData) {
              (options.data as FormData).fields.add(
                MapEntry('formhash', formhash!),
              );
            } else if (options.data is Map) {
              (options.data as Map)['formhash'] = formhash;
            } else {
              options.data ??= {'formhash': formhash};
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cookie 管理
  // ---------------------------------------------------------------------------

  /// 清除所有 Cookie 和登录状态（退出登录时调用）
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
    formhash = null;
    talker.info('已清除所有 Cookie 和 formhash');
  }

  // ---------------------------------------------------------------------------
  // 公共方法
  // ---------------------------------------------------------------------------

  /// 简单的连通性测试 (PING)
  Future<(bool, String)> ping(String url, {Duration? timeout}) async {
    talker.info('PING $url');
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          extra: {'withCredentials': true},
          sendTimeout: timeout ?? const Duration(seconds: 8),
          receiveTimeout: timeout ?? const Duration(seconds: 8),
        ),
      );
      return (true, response.data ?? '服务端无返回');
    } on DioException catch (e) {
      return (false, _errorMessage(e));
    }
  }

  /// GET 请求，返回 (成功?, 响应字符串)
  Future<(bool, String)> get(String url, {Map<String, String>? params}) async {
    try {
      final response = await _dio.get<String>(
        url,
        queryParameters: params,
        options: Options(extra: {'withCredentials': true}),
      );
      return (true, response.data ?? '服务端无返回');
    } on DioException catch (e) {
      final msg = _errorMessage(e);
      talker.error('GET $url 失败: $msg', e);
      return (false, msg);
    } catch (e) {
      talker.error('GET $url 异常: $e', e);
      return (false, '请求异常: $e');
    }
  }

  /// GET 请求，返回原始二进制数据 (用于验证码图片等)
  Future<(bool, Uint8List?)> getRaw(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Referer': loginUrl},
          extra: {'withCredentials': true},
        ),
      );
      final data = response.data;
      return (true, data != null ? Uint8List.fromList(data) : null);
    } on DioException catch (e) {
      talker.error('getRaw error', e);
      return (false, null);
    }
  }

  /// POST 请求
  ///
  /// 当 [multipart] 为 true 时使用 multipart/form-data 提交。
  /// 会自动注入 formhash（如果已设置）。
  Future<(bool, String)> post(
    String url, {
    Object? params,
    bool multipart = false,
  }) async {
    try {
      final response = await _dio.post<String>(
        url,
        data: multipart
            ? (params is FormData
                  ? params
                  : FormData.fromMap((params as Map<String, dynamic>?) ?? {}))
            : params,
        options: Options(
          contentType: multipart
              ? 'multipart/form-data'
              : Headers.formUrlEncodedContentType,
          extra: {'withCredentials': true},
        ),
      );
      return (true, response.data ?? '服务端无返回');
    } on DioException catch (e) {
      final msg = _errorMessage(e);
      talker.error('POST $url 失败: $msg', e);
      return (false, msg);
    } catch (e) {
      talker.error('POST $url 异常: $e', e);
      return (false, '请求异常: $e');
    }
  }

  /// POST 并跟随 302 重定向（Discuz 搜索等场景）。
  ///
  /// Discuz 搜索 POST 后返回 302，Location 携带 searchid。
  /// 本方法捕获 302，提取 Location，再 GET 拿到最终结果。
  Future<(bool, String)> postFollowRedirect(
    String url, {
    Object? params,
  }) async {
    try {
      final response = await _dio.post<String>(
        url,
        data: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          // 接受 302 状态码，不抛异常
          validateStatus: (status) =>
              status != null && (status < 400 || status == 302),
          // 不自动跟随重定向，手动处理
          followRedirects: false,
          extra: {'withCredentials': true},
        ),
      );

      // 如果是 302，提取 Location 并 GET
      if (response.statusCode == 302) {
        final location = response.headers.value('location');
        if (location == null || location.isEmpty) {
          return (false, '重定向地址为空');
        }
        // location 可能是相对路径，拼接 baseUrl
        final redirectUrl = location.startsWith('http')
            ? location
            : '$_baseUrl/$location';
        talker.info('POST 302 → GET $redirectUrl');
        return get(redirectUrl);
      }

      return (true, response.data ?? '服务端无返回');
    } on DioException catch (e) {
      final msg = _errorMessage(e);
      talker.error('POST $url 失败: $msg', e);
      return (false, msg);
    } catch (e) {
      talker.error('POST $url 异常: $e', e);
      return (false, '请求异常: $e');
    }
  }

  /// 上传图片附件
  ///
  /// [uploadUrl] 服务端图片上传接口，[uid] 与 [hash] 来自发帖页面的
  /// `uploadformdata` 字段。返回 `(成功?, 附件信息或错误信息)`，附件信息包含
  /// `aid` 与附件缩略图地址。
  Future<(bool, String)> uploadImage(
    String uploadUrl, {
    required String uid,
    required String hash,
    required Uint8List bytes,
    String filename = 'upload.jpg',
  }) async {
    final form = FormData.fromMap({
      'uid': uid,
      'hash': hash,
      'Filedata': MultipartFile.fromBytes(bytes, filename: filename),
    });

    final (ok, body) = await post(uploadUrl, params: form, multipart: true);
    if (!ok) return (false, body);

    if (!body.contains('|')) {
      return (false, body.isEmpty ? '上传失败，请稍后再试' : body);
    }

    final parts = body.split('|');
    if (parts[0] == 'DISCUZUPLOAD' && parts.length > 5 && parts[2] == '0') {
      final aid = parts[3];
      final serverPath = parts[5];
      final url = '$_baseUrl/data/attachment/forum/$serverPath';
      return (true, '$aid|$url');
    }

    final code = parts.length > 2 ? parts[2] : parts.first;
    final limitInfo = parts.length > 7 ? parts[7] : '';
    String serverMsg = '';
    if (limitInfo == 'ban') {
      serverMsg = '（附件类型被禁止）';
    } else if (limitInfo == 'perday' && parts.length > 8) {
      serverMsg = '（不能超过 ${int.parse(parts[8]) ~/ 1024} K）';
    } else if (limitInfo.isNotEmpty) {
      serverMsg = '（不能超过 ${int.parse(limitInfo) ~/ 1024} K）';
    }
    final mapped = uploadImageErrors[code];
    final msg = (mapped ?? '上传失败') + serverMsg;
    return (false, msg);
  }

  /// 从 DioException 中提取可读的错误信息
  static String _errorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        final timeout = e.requestOptions.connectTimeout;
        final sec = timeout != null ? timeout.inSeconds : 10;
        return '连接超时（${sec}s），请检查网络或代理设置';
      case DioExceptionType.sendTimeout:
        return '发送超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        return '接收超时，服务器响应过慢';
      case DioExceptionType.connectionError:
        final inner = e.error;
        if (inner is SocketException) {
          return '无法连接到服务器: ${inner.message}';
        }
        return '网络连接失败: ${e.message ?? "未知错误"}';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final url = e.requestOptions.uri.toString();
        switch (statusCode) {
          case 301:
          case 302:
            return '请求被重定向 ($statusCode)，可能需要登录';
          case 403:
            return '访问被拒绝 (403)，可能需要登录或权限不足';
          case 404:
            return '页面不存在 (404): $url';
          case 500:
            return '服务器内部错误 (500)';
          case 502:
          case 503:
            return '服务器暂时不可用 ($statusCode)';
          default:
            return 'HTTP 错误 $statusCode';
        }
      case DioExceptionType.cancel:
        return '请求被取消';
      case DioExceptionType.badCertificate:
        return 'SSL 证书验证失败，可能需要开启代理';
      default:
        return e.message ?? '未知网络错误';
    }
  }
}
