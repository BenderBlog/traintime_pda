// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// In history, this was from a website, but it is not nessary...

import 'dart:convert';
import 'package:watermeter/model/telephone.dart';

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
        "tel": ["029-88202768"]
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
