// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Dorm water drink session for Hui798 API.

import 'package:dio/dio.dart';
import 'package:watermeter/repository/network_session.dart';
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

class DormWaterSession extends NetworkSession {
  static const String apiBaseUrl = 'https://i.ilife798.com';
  
  /// Store current session ID for sending SMS code
  String? _currentSessionId;

  /// Generate a random session ID for captcha
  String _generateSessionId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
}
