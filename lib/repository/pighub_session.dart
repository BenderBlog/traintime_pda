// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// PigHub API session. https://www.pighub.top

import 'dart:math' as math;

import 'package:dio/dio.dart';

const _base = "https://www.pighub.top";

Dio get _dio => Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ),
);

class PigHubImage {
  final String id;
  final String thumbnail; // relative path, e.g. /data/xxx.jpg
  final String title;
  final String imageType; // "static" or "gif"

  const PigHubImage({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.imageType,
  });

  factory PigHubImage.fromJson(Map<String, dynamic> json) => PigHubImage(
    id: json["id"].toString(),
    thumbnail: json["thumbnail"].toString(),
    title: json["title"].toString(),
    imageType: json["image_type"].toString(),
  );

  /// Full URL of the image.
  String get url => "$_base$thumbnail";
}

List<dynamic> _extractImageList(dynamic data) {
  final dynamic payload = (data is Map<String, dynamic> && data["data"] != null)
      ? data["data"]
      : data;

  final dynamic imagesRaw = switch (payload) {
    Map<String, dynamic>() => payload["images"] ?? payload,
    List<dynamic>() => payload,
    _ => null,
  };

  if (imagesRaw is List<dynamic>) {
    return imagesRaw;
  }
  if (imagesRaw is Map<String, dynamic>) {
    return imagesRaw.values.toList();
  }
  throw const FormatException("Invalid PigHub response format.");
}

/// Fetches all images and returns one at random.
Future<PigHubImage> getRandomPig() async {
  final response = await _dio.get("$_base/api/all-images");

  final List<dynamic> images = _extractImageList(response.data);
  if (images.isEmpty) {
    throw Exception("PigHub returned an empty image list.");
  }

  final index = math.Random().nextInt(images.length);
  final item = images[index];
  if (item is! Map<String, dynamic>) {
    throw const FormatException("Invalid PigHub image item format.");
  }
  return PigHubImage.fromJson(item);
}
