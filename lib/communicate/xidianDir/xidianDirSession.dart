/*
Get data from Xidian Directory Database.

Copyright (C) 2022 SuperBart

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:watermeter/dataStruct/xidianDir/shop_information_entity.dart';
import 'package:watermeter/dataStruct/xidianDir/cafeteria_window_item_entity.dart';
import 'package:watermeter/dataStruct/xidianDir/telephone.dart';

class XidianDirectorySession {

  final String _apiKey = 'ya0UhH6yzo8nKmWyrHfkLEyb';
  final String _xlId = 'qvGPBI8zLfAyNs9yWxBxd0iW-MdYXbMMI';

  String sign() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${md5.convert(utf8.encode(timestamp.toString()+_apiKey))},$timestamp';
  }

  Map<String,String> _head() => {
    'X-LC-Id': _xlId,
    'X-LC-Sign': sign(),
    'referer': "https://ncov.hawa130.com/",
  };

  Dio get _dio{
    Dio toReturn = Dio();
    toReturn.options = BaseOptions(
      baseUrl: "https://ncov-api.hawa130.com/1.1/classes",
      headers: _head(),
    );
    toReturn.interceptors.add(
        DioCacheManager(
            CacheConfig(
                baseUrl: "https://ncov-api.hawa130.com/1.1/classes",
            )
        ).interceptor
    );
    return toReturn;
  }

  Future<String> require({
    required String subWebsite,
    required Map<String,String> body,
    bool isForce = false,
  }) async {
    var response = await _dio.get(
      subWebsite,
      queryParameters: body,
      options: buildCacheOptions(
        const Duration(days: 2),
        forceRefresh: isForce,
      ),
    );
    /// Cache is not working in Linux/Windows/Web due to the
    /// platform limitation of dio_http_cache.
    if (kDebugMode) {
      if (null != response.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE)) {
          print({"data source": "data come from cache"});

      } else {
        print({"data source": "data come from net"});
      }
    }
    /// Default return a Map<String,dynamic>, but I ordered him to get json!
    return json.encode(response.data).toString();
  }
}

var getTool = XidianDirectorySession();

/// Structure of the formula, getdata -> evaldata -> sendtowindow.
Future<ShopInformationEntity> getShopData({
  required String category,
  required String toFind,
  bool isForceUpdate = false
}) async {
  // Get Data
  String jsonData = await getTool.require(
    subWebsite: "/info",
    body: {
      'order': '-status,-updatedAt',
      'limit': '1000',
    },
    isForce: isForceUpdate,
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
  bool isForceUpdate = false
}) async {
  // Get data
  String jsonData = await getTool.require(
    subWebsite: "/canteen",
    body: {
      "where": "{\"place\":{\"\$regex\":\"$where\"}}",
      'order': '-status,-updatedAt',
      'limit': '1000',
    },
    isForce: isForceUpdate,
  );
  final jsonResult = CafeteriaWindowItemEntity.fromJson(json.decode(jsonData));
  if (toFind != "") {
    jsonResult.results.removeWhere(
            (i) => !i.name.contains(toFind) && !i.window.contains(toFind));
  }
  // Turn to the WindowInformation
  List<WindowInformation> toReturn = [];
  for (var i in jsonResult.results){
    // This window is not in the WindowInformation List
    if (!toReturn.any((j) => j.name == i.window)){
      toReturn.add(WindowInformation(
        name: i.window,
        places: i.place,
        updateTime: i.createdAt,
        number: i.number,
        commit: i.shopComment,
      ));
    }
    toReturn[toReturn.lastIndexWhere((j) => j.name == i.window)].items.add(
      WindowItemsGroup(
        name: i.name,
        price: i.price,
        unit: i.unit,
        status: i.status,
        commit: i.comment,
      )
    );
  }
  return toReturn;
}

Future<List<TeleyInformation>> getTelephoneData(bool isForceUpdate) async{
  List<TeleyInformation> toReturn = [];
  const addBook = "https://myxdu.moefactory.com/ncov/static/json/";
  var dio = Dio(BaseOptions(baseUrl: addBook));
  dio.interceptors.add(
      DioCacheManager(
          CacheConfig(
            baseUrl: "https://myxdu.moefactory.com/ncov/static/json/",
          )
      ).interceptor
  );
  var response = await dio.get(
    "data.json",
    options: buildCacheOptions(
      const Duration(days: 30),
      forceRefresh: isForceUpdate,
    ),
  );
  if (kDebugMode) {
    if (null != response.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE)) {
      print({"data source": "data come from cache"});

    } else {
      print({"data source": "data come from net"});
    }
  }
  for (var i in response.data){
    var toAdd = TeleyInformation(title: i['name']);
    for (var j in i['place']){
      if (j['campus'] == "北校区") {
        toAdd.isNorth = true;
        toAdd.northAddress = j['address'];
        if(j['tel'].isNotEmpty) {
          toAdd.northTeley = j['tel'].join(" 或 ");
        }
      }
      if (j['campus'] == "南校区") {
        toAdd.isSouth = true;
        toAdd.southAddress = j['address'];
        if(j['tel'].isNotEmpty) {
          toAdd.southTeley = j['tel'].join(" 或 ");
        }
      }
    }
    toReturn.add(toAdd);
  }
  return toReturn;
}