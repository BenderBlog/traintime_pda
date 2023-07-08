/*
Cafeteria Data Structure of the Xidian Directory.
Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

import 'package:json_annotation/json_annotation.dart';

part 'cafeteria_window_item.g.dart';

// Modified to simplify searching.
const categories = ['竹园一楼', '竹园二楼', '海棠一楼', '海棠二楼', '丁香'];

@JsonSerializable()
class CafeteriaWindowItemEntity {
  late List<CafeteriaWindowItemResults> results;

  CafeteriaWindowItemEntity();

  factory CafeteriaWindowItemEntity.fromJson(Map<String, dynamic> json) =>
      _$CafeteriaWindowItemEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CafeteriaWindowItemEntityToJson(this);
}

@JsonSerializable()
class CafeteriaWindowItemResults {
  late DateTime updatedAt;
  late String place;
  String? number;
  String unit = "份";
  String name = "录数据的看不清";
  late String objectId;
  late DateTime createdAt;
  late String window;
  bool status = true;
  late List<double> price;
  String? comment;
  String? shopComment;

  CafeteriaWindowItemResults();

  factory CafeteriaWindowItemResults.fromJson(Map<String, dynamic> json) =>
      _$CafeteriaWindowItemResultsFromJson(json);

  Map<String, dynamic> toJson() => _$CafeteriaWindowItemResultsToJson(this);
}

class WindowInformation {
  late String name;
  late String places;
  late DateTime updateTime;
  String? number;
  String? commit;
  Set<WindowItemsGroup> items = {};

  WindowInformation({
    required this.name,
    required this.places,
    required this.updateTime,
    this.number,
    required this.commit,
  });

  bool state() {
    for (var i in items) {
      if (i.status == true) {
        return true;
      }
    }
    return false;
  }

  void addItems(WindowItemsGroup toAdd) => items.add(toAdd);
}

class WindowItemsGroup {
  String name;
  List<double> price;
  String unit;
  late bool status;
  String? commit;

  WindowItemsGroup({
    required this.name,
    required this.price,
    required this.unit,
    this.status = true,
    this.commit,
  });
}
