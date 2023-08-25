// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// XDU Planet API.
// I will put my xduplanet.php to my github, which thanks to old computers.

import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';

class PlanetSession extends NetworkSession {
  static const base = "https://server.superbart.xyz/xduplanet.php";
  Future<RepoList> repoList() async {
    var response = await dio.get(base).then((value) => value.data);
    return RepoList.fromJson(response);
  }

  Future<TitleList> titleList(String author) async {
    var response =
        await dio.get("$base?feed=$author").then((value) => value.data);
    return TitleList.fromJson(response);
  }

  Future<Content> content(String author, int page) async {
    var response =
        await dio.get("$base?feed=$author&p=$page").then((value) => value.data);
    return Content.fromJson(response);
  }
}
