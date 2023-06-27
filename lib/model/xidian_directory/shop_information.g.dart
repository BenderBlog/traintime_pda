// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopInformationEntity _$ShopInformationEntityFromJson(
        Map<String, dynamic> json) =>
    ShopInformationEntity()
      ..results = (json['results'] as List<dynamic>)
          .map(
              (e) => ShopInformationResults.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ShopInformationEntityToJson(
        ShopInformationEntity instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

ShopInformationResults _$ShopInformationResultsFromJson(
        Map<String, dynamic> json) =>
    ShopInformationResults()
      ..category = json['category'] as String
      ..tags = (json['tags'] as List<dynamic>).map((e) => e as String).toList()
      ..updatedAt = DateTime.parse(json['updatedAt'] as String)
      ..name = json['name'] as String
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..status = json['status'] as bool
      ..objectId = json['objectId'] as String
      ..description = json['description'] as String?;

Map<String, dynamic> _$ShopInformationResultsToJson(
        ShopInformationResults instance) =>
    <String, dynamic>{
      'category': instance.category,
      'tags': instance.tags,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
      'objectId': instance.objectId,
      'description': instance.description,
    };
