// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/model/pighub_image.dart';
import 'package:watermeter/repository/network_client.dart';

class PighubSession with NetworkClient {
  // PigHub API session. https://www.pighub.top
  final _urlBase = "https://www.pighub.top";

  Future<List<PigHubImage>> getPigImages() => dio
      .get("$_urlBase/api/images?sort=0")
      .then(
        (response) => (response.data["data"] as List<dynamic>)
            .map((item) => PigHubImage.fromJson(item))
            .toList(),
      );
}
