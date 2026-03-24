// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Dorm water drink session for Hui798 API.

import 'package:dio/dio.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart';
import 'dart:math';
import 'dart:convert' show base64Encode;

/// Model class for captcha response
class CaptchaData {
  final String sessionId;
  final String imageBase64;

  CaptchaData({
    required this.sessionId,
    required this.imageBase64,
  });
}

/// Model class for device
class DormWaterDevice {
  final String id;
  final String name;

  DormWaterDevice({
    required this.id,
    required this.name,
  });

  factory DormWaterDevice.fromJson(Map<String, dynamic> json) {
    return DormWaterDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class DormWaterSession extends NetworkSession {
  static const String apiBaseUrl = 'https://i.ilife798.com';
  
  /// Store current session ID for sending SMS code
  String? _currentSessionId;

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
  Future<CaptchaData> getCaptcha() async {
    try {
      final sessionId = _generateSessionId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await dio.get(
        '$apiBaseUrl/api/v1/captcha/',
        queryParameters: {
          's': sessionId,
          'r': timestamp.toString(),
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final imageBase64 = base64Encode(response.data as List<int>).toString();
        // Store session ID for later SMS sending
        _currentSessionId = sessionId;
        return CaptchaData(
          sessionId: sessionId,
          imageBase64: imageBase64,
        );
      } else {
        throw Exception(
          'Failed to fetch captcha: ${response.statusCode}',
        );
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
      final response = await dio.post(
        '$apiBaseUrl/api/v1/acc/login/code',
        data: {
          's': _currentSessionId,
          'authCode': imageCode,
          'un': phoneNumber,
        },
        options: Options(
          contentType: Headers.jsonContentType,
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
        throw Exception(
          'Failed to send SMS: ${response.statusCode}',
        );
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
      final response = await dio.post(
        '$apiBaseUrl/api/v1/acc/login',
        data: {
          'cid': '',
          'authCode': smsCode,
          'un': phoneNumber,
        },
        options: Options(
          contentType: Headers.jsonContentType,
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
          
          return {
            'token': token,
            'uid': uid,
            'eid': eid,
          };
        } else {
          throw Exception(
            'Login failed: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Login failed: ${response.statusCode}',
        );
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

      final response = await dio.get(
        '$apiBaseUrl/api/v1/ui/app/master',
        options: Options(
          headers: {
            'Authorization': token,
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
          final List<dynamic> favos = responseData['favos'] as List<dynamic>? ?? [];
          
          return favos
              .map((device) => DormWaterDevice.fromJson(device as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Failed to fetch devices: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch devices: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch devices: $e');
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

      final response = await dio.get(
        '$apiBaseUrl/api/v1/dev/start',
        queryParameters: {
          'did': deviceId,
          'upgrade': 'true',
          'rcp': 'false',
          'stype': '5',
        },
        options: Options(
          headers: {
            'Authorization': token,
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
        throw Exception(
          'Failed to start water: ${response.statusCode}',
        );
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

      final response = await dio.get(
        '$apiBaseUrl/api/v1/dev/end',
        queryParameters: {
          'did': deviceId,
        },
        options: Options(
          headers: {
            'Authorization': token,
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
        throw Exception(
          'Failed to end water: ${response.statusCode}',
        );
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

      final response = await dio.get(
        '$apiBaseUrl/api/v1/ui/app/dev/status',
        queryParameters: {
          'did': deviceId,
          'more': 'true',
          'promo': 'false',
        },
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
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
        throw Exception(
          'Failed to check status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to check status: $e');
    }
  }
}
