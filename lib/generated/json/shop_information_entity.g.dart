import 'package:watermeter/model/xidian_directory/shop_information_entity.dart';
import 'package:watermeter/generated/json/base/json_convert_content.dart';

ShopInformationEntity $ShopInformationEntityFromJson(
    Map<String, dynamic> json) {
  final ShopInformationEntity shopInformationEntity = ShopInformationEntity();
  final List<ShopInformationResults>? results =
      jsonConvert.convertListNotNull<ShopInformationResults>(json['results']);
  if (results != null) {
    shopInformationEntity.results = results;
  }
  return shopInformationEntity;
}

Map<String, dynamic> $ShopInformationEntityToJson(
    ShopInformationEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['results'] = entity.results.map((v) => v.toJson()).toList();
  return data;
}

ShopInformationResults $ShopInformationResultsFromJson(
    Map<String, dynamic> json) {
  final ShopInformationResults shopInformationResults =
      ShopInformationResults();
  final String? category = jsonConvert.convert<String>(json['category']);
  if (category != null) {
    shopInformationResults.category = category;
  }
  final List<String>? tags =
      jsonConvert.convertListNotNull<String>(json['tags']);
  if (tags != null) {
    shopInformationResults.tags = tags;
  }
  final DateTime? updatedAt = jsonConvert.convert<DateTime>(json['updatedAt']);
  if (updatedAt != null) {
    shopInformationResults.updatedAt = updatedAt;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    shopInformationResults.name = name;
  }
  final DateTime? createdAt = jsonConvert.convert<DateTime>(json['createdAt']);
  if (createdAt != null) {
    shopInformationResults.createdAt = createdAt;
  }
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    shopInformationResults.status = status;
  }
  final String? objectId = jsonConvert.convert<String>(json['objectId']);
  if (objectId != null) {
    shopInformationResults.objectId = objectId;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    shopInformationResults.description = description;
  }
  return shopInformationResults;
}

Map<String, dynamic> $ShopInformationResultsToJson(
    ShopInformationResults entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['category'] = entity.category;
  data['tags'] = entity.tags;
  data['updatedAt'] = entity.updatedAt.toIso8601String();
  data['name'] = entity.name;
  data['createdAt'] = entity.createdAt.toIso8601String();
  data['status'] = entity.status;
  data['objectId'] = entity.objectId;
  data['description'] = entity.description;
  return data;
}
