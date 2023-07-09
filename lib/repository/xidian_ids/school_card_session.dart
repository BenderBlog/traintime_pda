/*
Get your school card money's info, unless you use wechat or alipay...

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
import 'dart:io';
import 'dart:developer' as developer;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class SchoolCardSession extends IDSSession {
  Future<void> loginCard() async {
    developer.log(
      "try to get card money",
      name: "SchoolCardSession",
    );
    var response = await dio.get(
      "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page",
    );
    while (response.headers[HttpHeaders.locationHeader] != null) {
      String location = response.headers[HttpHeaders.locationHeader]![0];
      developer.log("Received: $location.", name: "SchoolCardSession");
      response = await dio.get(location);
    }
    var money = BeautifulSoup(response.data).find(
      'span',
      attrs: {"name": "showbalanceid"},
    );
    developer.log(
      "Card money: ${money!.innerHtml}",
      name: "SchoolCardSession",
    );
  }
}
