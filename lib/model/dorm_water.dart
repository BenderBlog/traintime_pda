// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

class DormWaterCaptchaData {
  final String sessionId;
  final String imageBase64;

  DormWaterCaptchaData({required this.sessionId, required this.imageBase64});
}

class DormWaterDevice {
  final String id;
  final String name;

  DormWaterDevice({required this.id, required this.name});

  factory DormWaterDevice.fromJson(Map<String, dynamic> json) {
    return DormWaterDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
