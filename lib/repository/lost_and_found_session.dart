// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:watermeter/model/lost_and_found.dart';
import 'package:watermeter/repository/network_session.dart';

class LostAndFoundSession extends NetworkSession {
  static const base = "https://find.xidian.edu.cn/api/public/index.php";

  Future<List<LostAndFoundInfo>> getList({
    required int page,
    required String type,
    required String keyword,
  }) async {
    return await dio
        .post(
      "$base/laf/item_list/get",
      data: FormData.fromMap({
        "page": page,
        "keywords": keyword,
        "category": "",
        "code": "",
        "type": type,
        "item_id": "-1",
      }),
    )
        .then(
      (value) {
        if (value.data["code"] != 200) {
          throw NoDataException(msg: value.data["message"] ?? "获取数据失败");
        }
        return LostAndFoundList.fromJson(value.data).item_list;
      },
    );
  }

  Future<LostAndFoundInfo> getItem({
    required int id,
  }) async {
    return await dio
        .post(
      "$base/laf/item_list/get",
      data: FormData.fromMap({
        "item_id": id,
      }),
    )
        .then(
      (value) {
        if (value.data["code"] != 200) {
          throw NoDataException(msg: value.data["message"] ?? "获取数据失败");
        }
        return LostAndFoundList.fromJson(value.data).item_list.first;
      },
    );
  }
}

class NoDataException implements Exception {
  final String msg;
  NoDataException({required this.msg});
}
