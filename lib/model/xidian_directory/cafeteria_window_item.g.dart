// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cafeteria_window_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CafeteriaWindowItemEntity _$CafeteriaWindowItemEntityFromJson(
        Map<String, dynamic> json) =>
    CafeteriaWindowItemEntity()
      ..results = (json['results'] as List<dynamic>)
          .map((e) =>
              CafeteriaWindowItemResults.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$CafeteriaWindowItemEntityToJson(
        CafeteriaWindowItemEntity instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

CafeteriaWindowItemResults _$CafeteriaWindowItemResultsFromJson(
        Map<String, dynamic> json) =>
    CafeteriaWindowItemResults()
      ..updatedAt = DateTime.parse(json['updatedAt'] as String)
      ..place = json['place'] as String
      ..number = json['number'] as String?
      ..unit = json['unit'] as String
      ..name = json['name'] as String
      ..objectId = json['objectId'] as String
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..window = json['window'] as String
      ..status = json['status'] as bool
      ..price = (json['price'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList()
      ..comment = json['comment'] as String?
      ..shopComment = json['shopComment'] as String?;

Map<String, dynamic> _$CafeteriaWindowItemResultsToJson(
        CafeteriaWindowItemResults instance) =>
    <String, dynamic>{
      'updatedAt': instance.updatedAt.toIso8601String(),
      'place': instance.place,
      'number': instance.number,
      'unit': instance.unit,
      'name': instance.name,
      'objectId': instance.objectId,
      'createdAt': instance.createdAt.toIso8601String(),
      'window': instance.window,
      'status': instance.status,
      'price': instance.price,
      'comment': instance.comment,
      'shopComment': instance.shopComment,
    };
