/*
XDU Planet API. 
Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

I will put my xduplanet.php to my github, which thanks to old computers.
*/

import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';

class PlanetSession extends NetworkSession {
  static const base = "https://server.superbart.xyz/xduplanet.php";
  Future<RepoList> repoList() async {
    var response = await dio.get(base).then((value) => value.data);
    return RepoList.fromJson(response);
  }

  Future<TitleList> titleList(String author) async {
    var response = await dio.get(base, data: {
      "feed": author,
    }).then((value) => value.data);
    return TitleList.fromJson(response);
  }

  Future<Content> content(String author, int page) async {
    var response = await dio.get(base, data: {
      "feed": author,
      "p": page,
    }).then((value) => value.data);
    return Content.fromJson(response);
  }
}
