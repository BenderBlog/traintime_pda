/*
Get your school card money's info, unless you use wechat or alipay...

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

var money = "".obs;

class SchoolCardSession extends IDSSession {
  static String virtualCardUrl = "";
  static String personalCenter = "";

  Future<void> getQRCode() async {
    developer.log(
      "try to get QR Code",
      name: "SchoolCardSession",
    );
    var response = await dio
        .get(
          "https://v8scan.xidian.edu.cn/$virtualCardUrl",
        )
        .then(
          (value) => BeautifulSoup(value.data),
        );
    developer
        .log(response.find('img', id: "qrcode")?.attributes.toString() ?? "");
  }

  Future<void> getMoney() async {
    developer.log(
      "$virtualCardUrl\n$personalCenter",
      name: "SchoolCardSessionGetMoney",
    );
    developer.log(
      "https://v8scan.xidian.edu.cn/$personalCenter",
      name: "SchoolCardSessionGetMoney",
    );

    var response = await dio
        .get(
          "https://v8scan.xidian.edu.cn/$personalCenter",
        )
        .then(
          (value) => BeautifulSoup(value.data),
        );
    var source = response.ul!.children[0].findAll('p');
    money.value = source[1].innerHtml;
    developer.log(
      "Money amount is ${money.value}",
      name: "SchoolCardSession",
    );
  }

  Future<void> init() async {
    var response = await dio.get(
      "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page",
    );
    while (response.headers[HttpHeaders.locationHeader] != null) {
      String location = response.headers[HttpHeaders.locationHeader]![0];
      developer.log("Received: $location.", name: "SchoolCardSession");
      response = await dio.get(location);
    }
    var page = BeautifulSoup(response.data);

    var allA = page.findAll('a');
    for (var element in allA) {
      if (element["href"]?.contains("openVirtualcard") ?? false) {
        virtualCardUrl += element["href"]!;
      }
      if (element["href"]?.contains("openMyAccount") ?? false) {
        personalCenter += element["href"]!;
      }
    }
  }
}
