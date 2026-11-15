// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';

import '../model/pighub_image.dart';

class PighubSession {
  const PighubSession(this.dio);

  final Dio dio;

  Future<List<PigHubImage>> getPigImages() async {
    final response = await dio.get('https://www.pighub.top/api/images?sort=0');
    return (response.data['data'] as List<dynamic>)
        .map((item) => PigHubImage.fromJson(item as Map<String, dynamic>))
        .toList()
      ..shuffle();
  }
}
