// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Dorm water drink session for Hui798 API.
// TODO: Move Dorm Water from repo to external

import 'dart:convert' show base64Encode;
import 'dart:io' show HttpHeaders, Platform;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:watermeter/model/dorm_water.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart';

class DormWaterSession {
  static const String apiBaseUrl = 'https://i.ilife798.com';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      contentType: Headers.formUrlEncodedContentType,
      headers: {HttpHeaders.userAgentHeader: _getUserAgent()},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: false,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    ),
  )..interceptors.add(logDioAdapter);

  /// Store current session ID for sending SMS code
  String? _currentSessionId;

  /// Get User-Agent based on platform
  ///
  /// iOS:
  ///   - Captcha: iLife798/3.1.1 (iPhone; iOS 26.2; Scale/3.00)
  ///   - Others: iOS_ilife798_3.1.1
  /// Android:
  ///   - All: Android_ilife798_2.0.11
  /// Other platforms: Same as iOS
  static String _getUserAgent({bool isCaptcha = false}) {
    if (Platform.isAndroid) {
      return 'Android_ilife798_2.0.11';
    }
    return isCaptcha
        ? 'iLife798/3.1.1 (iPhone; iOS 26.2; Scale/3.00)'
        : 'iOS_ilife798_3.1.1';
  }

  /// Generate a random numeric session ID for captcha
  String _generateSessionId() {
    const chars = '0123456789';
    final random = Random();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Fetch captcha image from Hui798 API
  ///
  /// Returns CaptchaData containing:
  /// - sessionId: Session ID for subsequent API calls (generated randomly)
  /// - imageBase64: Base64-encoded captcha image
  Future<DormWaterCaptchaData> getCaptcha() async {
    try {
      final sessionId = _generateSessionId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await _dio.get(
        '/api/v1/captcha/',
        queryParameters: {'s': sessionId, 'r': timestamp.toString()},
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'accept': '*/*',
            'User-Agent': _getUserAgent(isCaptcha: true),
            'priority': 'u=3, i',
            'accept-language': 'zh-Hans-US;q=1, el-US;q=0.9, en-US;q=0.8',
            'accept-encoding': 'gzip, deflate, br',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final imageBase64 = base64Encode(response.data as List<int>).toString();
        // Store session ID for later SMS sending
        _currentSessionId = sessionId;
        return DormWaterCaptchaData(
          sessionId: sessionId,
          imageBase64: imageBase64,
        );
      } else {
        throw Exception('Failed to fetch captcha: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get captcha: $e');
    }
  }

  /// Send SMS code to user's phone
  ///
  /// Parameters:
  /// - [phoneNumber]: User's phone number
  /// - [imageCode]: Image captcha code entered by user
  ///
  /// Returns: Success message if SMS sent successfully
  Future<String> sendSmsCode({
    required String phoneNumber,
    required String imageCode,
  }) async {
    if (_currentSessionId == null) {
      throw Exception('No active session. Please load captcha first.');
    }

    try {
      final response = await _dio.post(
        '/api/v1/acc/login/code',
        data: {
          's': _currentSessionId,
          'authCode': imageCode,
          'un': phoneNumber,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': '*/*',
            'content-type': 'application/json',
            'accept-encoding': 'gzip, deflate, br',
            'priority': 'u=3, i',
            'accept-language': 'zh-Hans-US;q=1, el-US;q=0.9, en-US;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'];

        if (code == 0) {
          return 'SMS sent successfully';
        } else {
          throw Exception(
            'Failed to send SMS: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to send SMS: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send SMS: $e');
    }
  }

  /// Login with SMS code
  ///
  /// Parameters:
  /// - [phoneNumber]: User's phone number
  /// - [smsCode]: SMS code received by user
  ///
  /// Returns: Login response containing uid, eid, and token
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String smsCode,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/acc/login',
        data: {'cid': '', 'authCode': smsCode, 'un': phoneNumber},
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': '*/*',
            'content-type': 'application/json',
            'accept-encoding': 'gzip, deflate, br',
            'priority': 'u=3, i',
            'accept-language': 'zh-Hans-US;q=1, el-US;q=0.9, en-US;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'];

        if (code == 0) {
          final responseData = data['data'] as Map<String, dynamic>;
          final al = responseData['al'] as Map<String, dynamic>;

          final token = al['token'] as String;
          final uid = al['uid'] as String;
          final eid = al['eid'] as String;

          // Save token and credentials
          await setString(Preference.dormWaterToken, token);
          await setString(Preference.dormWaterUid, uid);
          await setString(Preference.dormWaterEid, eid);

          return {'token': token, 'uid': uid, 'eid': eid};
        } else {
          throw Exception('Login failed: ${data['msg'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Fetch device list from master endpoint
  ///
  /// Requires valid token to be saved in preferences
  /// Returns list of DormWaterDevice objects
  Future<List<DormWaterDevice>> getDeviceList() async {
    try {
      final token = getString(Preference.dormWaterToken);
      if (token.isEmpty) {
        throw Exception('No valid token. Please login first.');
      }

      final response = await _dio.get(
        '/api/v1/ui/app/master',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': token,
            'accept-encoding': 'gzip, deflate, br',
            'priority': 'u=3, i',
            'accept-language': 'zh-Hans-US;q=1, el-US;q=0.9, en-US;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'];

        if (code == 0) {
          final responseData = data['data'] as Map<String, dynamic>;

          // Check if login is still valid
          if (responseData['account'] == null) {
            throw Exception('Login expired. Please login again.');
          }

          // Get favorite devices
          final List<dynamic> favos =
              responseData['favos'] as List<dynamic>? ?? [];

          return favos
              .map(
                (device) =>
                    DormWaterDevice.fromJson(device as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'Failed to fetch devices: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to fetch devices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch devices: $e');
    }
  }

  /// Toggle device favorite status (favorite or unfavorite)
  ///
  /// Parameters:
  /// - [deviceId]: Device ID to favorite/unfavorite
  /// - [remove]: If true, remove from favorites; if false, add to favorites
  ///
  /// Returns: Success message
  Future<String> toggleDeviceFavorite({
    required String deviceId,
    required bool remove,
  }) async {
    try {
      final token = getString(Preference.dormWaterToken);
      if (token.isEmpty) {
        throw Exception('No valid token. Please login first.');
      }

      final response = await _dio.get(
        '/api/v1/dev/favo',
        queryParameters: {'did': deviceId, 'remove': remove.toString()},
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': token,
            'accept-encoding': 'gzip, deflate, br',
            'priority': 'u=3, i',
            'accept-language': 'zh-Hans-US;q=1, el-US;q=0.9, en-US;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'];

        if (code == 0) {
          final message = remove
              ? 'Device removed from favorites'
              : 'Device added to favorites';
          return message;
        } else {
          throw Exception(
            'Failed to update favorite: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to update favorite: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update favorite: $e');
    }
  }

  /// Start water dispensing
  ///
  /// Parameters:
  /// - [deviceId]: Device ID to start water dispensing
  ///
  /// Returns: Success message
  Future<String> startWater({required String deviceId}) async {
    try {
      final token = getString(Preference.dormWaterToken);
      if (token.isEmpty) {
        throw Exception('No valid token. Please login first.');
      }

      final response = await _dio.get(
        '/api/v1/dev/start',
        queryParameters: {
          'args': '',
          'cnt': '1',
          'did': deviceId,
          'pip': '21',
          'rcp': '0',
          'upgrade': '1',
        },
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': token,
            'accept-encoding': 'gzip, deflate, br',
            'priority': 'u=3, i',
            'accept-language': 'zh-Hans-US;q=1, el-US;q=0.9, en-US;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'];

        if (code == 0) {
          return 'Water dispensing started';
        } else {
          throw Exception(
            'Failed to start water: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to start water: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to start water: $e');
    }
  }

  /// End water dispensing
  ///
  /// Parameters:
  /// - [deviceId]: Device ID to end water dispensing
  ///
  /// Returns: Success message
  Future<String> endWater({required String deviceId}) async {
    try {
      final token = getString(Preference.dormWaterToken);
      if (token.isEmpty) {
        throw Exception('No valid token. Please login first.');
      }

      final response = await _dio.get(
        '/api/v1/dev/end',
        queryParameters: {'did': deviceId},
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': token,
            'accept-encoding': 'gzip, deflate, br',
            'priority': 'u=3, i',
            'accept-language': 'zh-Hans-US;q=1, el-US;q=0.9, en-US;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'];

        if (code == 0) {
          return 'Water dispensing ended';
        } else {
          throw Exception(
            'Failed to end water: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to end water: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to end water: $e');
    }
  }

  /// Check device status
  ///
  /// Parameters:
  /// - [deviceId]: Device ID to check status
  ///
  /// Returns: Device status (99 = available/idle)
  Future<int> checkDeviceStatus({required String deviceId}) async {
    try {
      final token = getString(Preference.dormWaterToken);
      if (token.isEmpty) {
        throw Exception('No valid token. Please login first.');
      }

      final response = await _dio.get(
        '/api/v1/ui/app/dev/status',
        queryParameters: {'did': deviceId, 'more': 'true', 'promo': 'false'},
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'];

        if (code == 0) {
          final responseData = data['data'] as Map<String, dynamic>;
          final device = responseData['device'] as Map<String, dynamic>;
          final gene = device['gene'] as Map<String, dynamic>;
          final status = gene['status'] as int;

          return status;
        } else {
          throw Exception(
            'Failed to check status: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to check status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to check status: $e');
    }
  }
}
