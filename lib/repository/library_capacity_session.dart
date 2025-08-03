// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:result_dart/result_dart.dart';
import 'package:watermeter/model/library_capacity.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/pda_service_session.dart';

Rx<Result<LibraryCapacity>> northStatus =
    LibraryCapacity(occupancy: 0, availableSeats: 0).toSuccess<Exception>().obs;
Rx<Result<LibraryCapacity>> southStatus =
    LibraryCapacity(occupancy: 0, availableSeats: 0).toSuccess<Exception>().obs;

enum LibraryCapacityErrorStatus {
  noDataDiv,
  notEnoughParams,
  noNumElement,
}

class LibraryCapacityParseException implements Exception {
  final LibraryCapacityErrorStatus variant;

  LibraryCapacityParseException({required this.variant});
}

Future<void> update() {
  northStatus = LibraryCapacity(occupancy: 0, availableSeats: 0)
      .toSuccess<Exception>()
      .obs;
  southStatus = LibraryCapacity(occupancy: 0, availableSeats: 0)
      .toSuccess<Exception>()
      .obs;
  log.info("[LibraryCapacity] ready to fetch info.");
  return Future.wait([
    Future(() async {
      northStatus.value = await getData(isNorthCampus: true);
    }),
    Future(() async {
      southStatus.value = await getData();
    }),
  ]);
}

Future<Result<LibraryCapacity>> getData({bool isNorthCampus = false}) async {
  final sversion = "d713ebdf67574ea7048e3a73c4a55f881569";
  final String southUrl =
      "https://lib.xidian.edu.cn/application/view/33996/data?sversion="
      "$sversion&mobile=1&wfwfid=2403&websiteId=13313&pageId=14305";
  final String northUrl =
      "https://lib.xidian.edu.cn/application/view/33992/data?sversion="
      "$sversion&mobile=1&wfwfid=2403&websiteId=13313&pageId=1430";

  try {
    final response = await dio
        .get(isNorthCampus ? northUrl : southUrl)
        .timeout(const Duration(seconds: 15));

    // 4. 从JSON中提取HTML内容
    final htmlContent = response.data['data']?['div'];
    if (htmlContent == null) {
      //print('错误：在API响应中找不到 "data.div" 字段。');
      return Failure(LibraryCapacityParseException(
        variant: LibraryCapacityErrorStatus.noDataDiv,
      ));
    }

    final document = html_parser.parse(htmlContent);

    // 6. 使用CSS选择器查找元素 (类似于 aoup.select)
    final items = document.querySelectorAll('ul.eng-tabs-info > li');
    if (items.length < 2) {
      //print('错误：在返回的HTML中未找到足够的数据项。');
      return Failure(LibraryCapacityParseException(
        variant: LibraryCapacityErrorStatus.notEnoughParams,
      ));
    }

    // 7. 提取数字并转换为整数
    final occupancyText = items[0].querySelector('.num')?.text.trim();
    final seatsText = items[1].querySelector('.num')?.text.trim();

    if (occupancyText == null || seatsText == null) {
      //print('错误：未能从HTML元素中找到包含数字的.num子元素。');
      return Failure(LibraryCapacityParseException(
        variant: LibraryCapacityErrorStatus.noNumElement,
      ));
    }

    final int occupancy = int.parse(occupancyText);
    final int availableSeats = int.parse(seatsText);

    // 8. 返回一个包含结果的OccupancyData对象
    return LibraryCapacity(
      occupancy: occupancy,
      availableSeats: availableSeats,
    ).toSuccess();
  } catch (e) {
    if (e is! Exception) {
      return Exception(e).toFailure();
    }
    return e.toFailure();
  }
}
