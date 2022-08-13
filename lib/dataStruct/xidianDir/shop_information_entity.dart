/*
Comprehensive Shop Data Structure of the Xidian Directory.
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
import 'package:watermeter/generated/json/shop_information_entity.g.dart';

// Modified to simplify searching.
const categories = ['所有', '饮食', '生活', '打印', '学习', '快递', '超市', '饮用水'];

@JsonSerializable()
class ShopInformationEntity {
  late List<ShopInformationResults> results;

  ShopInformationEntity();

  factory ShopInformationEntity.fromJson(Map<String, dynamic> json) =>
      $ShopInformationEntityFromJson(json);

  Map<String, dynamic> toJson() => $ShopInformationEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class ShopInformationResults {
  late String category;
  late List<String> tags;
  late DateTime updatedAt;
  late String name;
  late DateTime createdAt;
  late bool status;
  late String objectId;
  String? description;

  ShopInformationResults();

  factory ShopInformationResults.fromJson(Map<String, dynamic> json) =>
      $ShopInformationResultsFromJson(json);

  Map<String, dynamic> toJson() => $ShopInformationResultsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
