// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// XDU Planet API.
// I will put my xduplanet.php to my github, which thanks to old computers.

import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';

class PlanetSession extends NetworkSession {
  //static const base = "https://server.superbart.xyz/xduplanet.php";
  static const base = "https://xdlinux.github.io/planet";

  /*
  Future<RepoList> repoList() async {
    var response = await dio.get(base).then((value) => value.data);
    return RepoList.fromJson(response);
  }

  Future<TitleList> titleList(String author) async {
    var response =
        await dio.get("$base?feed=$author").then((value) => value.data);
    return TitleList.fromJson(response);
  }
  */

  Future<String> content(String dbPath) async {
    return await dio
        .get("$base/${Uri.encodeComponent(dbPath)}")
        .then((value) => value.data);
  }

  Future<XDUPlanetDatabase> repoList() async {
    return await dio
        .get("$base/index.json")
        .then((value) => XDUPlanetDatabase.fromJson(value.data));
  }
}
