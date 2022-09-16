/*
Cafeteria Data Structure of the Xidian Directory.
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

import 'package:watermeter/generated/json/base/json_field.dart';
import 'package:watermeter/generated/json/cafeteria_window_item_entity.g.dart';

// Modified to simplify searching.
const categories = ['竹园一楼', '竹园二楼', '海棠一楼', '海棠二楼', '丁香'];

@JsonSerializable()
class CafeteriaWindowItemEntity {
  late List<CafeteriaWindowItemResults> results;

  CafeteriaWindowItemEntity();

  factory CafeteriaWindowItemEntity.fromJson(Map<String, dynamic> json) =>
      $CafeteriaWindowItemEntityFromJson(json);

  Map<String, dynamic> toJson() => $CafeteriaWindowItemEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class CafeteriaWindowItemResults {
  late DateTime updatedAt;
  late String place;
  int? number;
  String unit = "份";
  String name = "录数据的看不清";
  late String objectId;
  late DateTime createdAt;
  late String window;
  bool status = true;
  late List<int> price;
  String? comment;
  String? shopComment;

  CafeteriaWindowItemResults();

  factory CafeteriaWindowItemResults.fromJson(Map<String, dynamic> json) =>
      $CafeteriaWindowItemResultsFromJson(json);

  Map<String, dynamic> toJson() => $CafeteriaWindowItemResultsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class WindowInformation {
  late String name;
  late String places;
  late DateTime updateTime;
  int? number;
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
  List<int> price;
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
