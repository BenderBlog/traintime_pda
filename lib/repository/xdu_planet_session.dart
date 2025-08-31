// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// XDU Planet API.
// I will put my xduplanet.php to my github, which thanks to old computers.

import 'package:dio/dio.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';

class PlanetSession extends NetworkSession {
  static const base = "https://xdlinux.github.io/planet";
  static const commentBase = "https://planet.iris.al";

  Future<List<XDUPlanetComment>> getComments(String id) =>
      dio.get("$commentBase/api/v1/comment/$id").then((value) {
        List<XDUPlanetComment> toReturn = [];
        value.data.forEach(
          (value) => toReturn.add(XDUPlanetComment.fromJson(value)),
        );
        return toReturn;
      });

  Future<String> sendComments({
    required String id,
    required String content,
    required String userId,
    required String? replyto,
  }) => dio
      .post(
        "$commentBase/api/v1/comment/$id",
        data: {
          "content": content,
          "user_id": userId,
          "reply_to": replyto ?? "",
        },
        options: Options(contentType: Headers.jsonContentType),
      )
      .then((value) => value.data.toString());

  Future<void> auditComments({required int id}) => dio
      .delete("$commentBase/api/v1/comment/$id")
      .then((value) => value.data.toString());

  Future<String> content(String dbPath) => dio
      .get("$base/${Uri.encodeComponent(dbPath)}")
      .then((value) => value.data);

  Future<XDUPlanetDatabase> repoList() => dio
      .get("$base/index.json")
      .then((value) => XDUPlanetDatabase.fromJson(value.data));
}
