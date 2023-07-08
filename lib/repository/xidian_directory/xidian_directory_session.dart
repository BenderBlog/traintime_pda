/*
Get data from Xidian Directory Database.

Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:watermeter/model/xidian_directory/cafeteria_window_item.dart';
import 'package:watermeter/model/xidian_directory/shop_information.dart';
import 'package:watermeter/model/xidian_directory/telephone.dart';

const String _apiKey = 'ya0UhH6yzo8nKmWyrHfkLEyb';
const String _xlId = 'qvGPBI8zLfAyNs9yWxBxd0iW-MdYXbMMI';

String sign() {
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${md5.convert(utf8.encode(timestamp.toString() + _apiKey))},$timestamp';
}

Map<String, String> _head() => {
      'X-LC-Id': _xlId,
      'X-LC-Sign': sign(),
      'referer': "https://ncov.hawa130.com/",
    };

Dio get _dio {
  Dio toReturn = Dio();
  toReturn.options = BaseOptions(
    baseUrl: "https://ncov-api.hawa130.com/1.1/classes",
    headers: _head(),
  );
  return toReturn;
}

Future<String> require({
  required String subWebsite,
  required Map<String, String> body,
}) async {
  var response = await _dio.get(
    subWebsite,
    queryParameters: body,
  );

  /// Default return a Map<String,dynamic>, but I ordered him to get json!
  return json.encode(response.data).toString();
}

/// Structure of the formula, getdata -> evaldata -> sendtowindow.
Future<ShopInformationEntity> getShopData({
  required String category,
  required String toFind,
  bool isForceUpdate = false,
}) async {
  // Get Data
  String jsonData = await require(
    subWebsite: "/info",
    body: {
      'order': '-status,-updatedAt',
      'limit': '1000',
    },
  );
  // Choose Data
  final jsonResult = ShopInformationEntity.fromJson(json.decode(jsonData));
  if (category != "所有") {
    jsonResult.results.removeWhere((i) => i.category != category);
  }
  if (toFind != "") {
    jsonResult.results.removeWhere(
        (i) => !i.name.contains(toFind) && !i.tags.contains(toFind));
  }
  return jsonResult;
}

/// Memory want to say dirty words.
Future<List<WindowInformation>> getCafeteriaData({
  required String where,
  required String toFind,
  bool isForceUpdate = false,
}) async {
  // Get data
  String jsonData = await require(
    subWebsite: "/canteen",
    body: {
      "where": "{\"place\":{\"\$regex\":\"$where\"}}",
      'order': '-status,-updatedAt',
      'limit': '1000',
    },
  );
  final jsonResult = CafeteriaWindowItemEntity.fromJson(json.decode(jsonData));
  if (toFind != "") {
    jsonResult.results.removeWhere(
        (i) => !i.name.contains(toFind) && !i.window.contains(toFind));
  }
  // Turn to the WindowInformation
  List<WindowInformation> toReturn = [];
  for (var i in jsonResult.results) {
    // This window is not in the WindowInformation List
    if (!toReturn.any((j) => j.name == i.window)) {
      toReturn.add(WindowInformation(
        name: i.window,
        places: i.place,
        updateTime: i.createdAt,
        number: i.number,
        commit: i.shopComment,
      ));
    }
    toReturn[toReturn.lastIndexWhere((j) => j.name == i.window)]
        .items
        .add(WindowItemsGroup(
          name: i.name,
          price: i.price,
          unit: i.unit,
          status: i.status,
          commit: i.comment,
        ));
  }
  return toReturn;
}

// In history, this was from a website, but it is not nessary...
List<TeleyInformation> getTelephoneData() {
  List<TeleyInformation> toReturn = [];
  var result = json.decode('''
[
  {
    "name": "教务处",
    "place": [
      {
        "campus": "南校区",
        "address": "行政楼 I 区 207",
        "tel": ["029-81891205"]
      }
    ]
  },
  {
    "name": "本科生招生办公室",
    "place": [
      { "campus": "北校区", "address": "办公楼一层西", "tel": ["029-88202335"] }
    ]
  },
  {
    "name": "研究生招生办公室",
    "place": [
      {
        "campus": "北校区",
        "address": "办公楼一层东 112 室",
        "tel": ["029-88201947"]
      }
    ]
  },
  {
    "name": "就业指导中心",
    "place": [
      {
        "campus": "北校区",
        "address": "逸夫图书馆西裙楼 302 室",
        "tel": ["029-88202234"]
      },
      { "campus": "南校区", "address": "EI-105", "tel": ["029-81891196"] }
    ]
  },
  {
    "name": "医院急诊室",
    "place": [
      {
        "campus": "北校区",
        "address": "西电社区西南门口",
        "tel": ["029-88202779"]
      },
      { "campus": "南校区", "address": "校医院门诊部", "tel": ["029-81891203"] }
    ]
  },
  {
    "name": "保卫处总值班室",
    "place": [
      {
        "campus": "北校区",
        "address": "西大楼西公安处楼",
        "tel": ["029-88201110"]
      },
      { "campus": "南校区", "address": "行政辅楼一层", "tel": ["029-81891110"] }
    ]
  },
  {
    "name": "信息中心用户服务部",
    "place": [
      {
        "campus": "北校区",
        "address": "教辅楼东一层",
        "tel": ["029-88201252"]
      },
      {
        "campus": "南校区",
        "address": "一站式大厅 22 号工位",
        "tel": ["029-81892115"]
      }
    ]
  },
  {
    "name": "后勤一站式服务平台",
    "place": [
      {
        "campus": "北校区",
        "address": "能源收费厅北侧",
        "tel": ["029-88201000"]
      }
    ]
  },
  {
    "name": "能源收费厅",
    "place": [
      {
        "campus": "北校区",
        "address": "西南门内浴室一层",
        "tel": ["029-88204726"]
      },
      {
        "campus": "南校区",
        "address": "图书馆东侧一站式服务大厅",
        "tel": ["029-81892100"]
      }
    ]
  },
  {
    "name": "水、电维修",
    "place": [
      {
        "campus": "北校区",
        "address": "浴室北侧",
        "tel": ["029-88202768", "029-88201224"]
      },
      {
        "campus": "南校区",
        "address": "E-II 立远物业",
        "tel": ["029-81891015"]
      }
    ]
  },
  {
    "name": "一站式服务大厅",
    "place": [
      { "campus": "北校区", "address": "逸夫图书馆西裙楼一层", "tel": [] },
      { "campus": "南校区", "address": "图书馆东侧", "tel": [] }
    ]
  }
]
''');
  for (var i in result) {
    var toAdd = TeleyInformation(title: i['name']);
    for (var j in i['place']) {
      if (j['campus'] == "北校区") {
        toAdd.isNorth = true;
        toAdd.northAddress = j['address'];
        if (j['tel'].isNotEmpty) {
          toAdd.northTeley = j['tel'].join(" 或 ");
        }
      }
      if (j['campus'] == "南校区") {
        toAdd.isSouth = true;
        toAdd.southAddress = j['address'];
        if (j['tel'].isNotEmpty) {
          toAdd.southTeley = j['tel'].join(" 或 ");
        }
      }
    }
    toReturn.add(toAdd);
  }
  return toReturn;
}
