/*
Comprehensive Shop Data Structure of the Xidian Directory.
Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/
import 'package:json_annotation/json_annotation.dart';

part 'shop_information.g.dart';

// Modified to simplify searching.
const categories = ['所有', '饮食', '生活', '打印', '学习', '快递', '超市', '饮用水'];

@JsonSerializable()
class ShopInformationEntity {
  late List<ShopInformationResults> results;

  ShopInformationEntity();

  factory ShopInformationEntity.fromJson(Map<String, dynamic> json) =>
      _$ShopInformationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ShopInformationEntityToJson(this);
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
      _$ShopInformationResultsFromJson(json);

  Map<String, dynamic> toJson() => _$ShopInformationResultsToJson(this);
}
