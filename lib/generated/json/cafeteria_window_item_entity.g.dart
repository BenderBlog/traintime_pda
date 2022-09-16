import 'package:watermeter/dataStruct/xidianDir/cafeteria_window_item_entity.dart';
import 'package:watermeter/generated/json/base/json_convert_content.dart';

CafeteriaWindowItemEntity $CafeteriaWindowItemEntityFromJson(
    Map<String, dynamic> json) {
  final CafeteriaWindowItemEntity cafeteriaWindowItemEntity =
      CafeteriaWindowItemEntity();
  final List<CafeteriaWindowItemResults>? results = jsonConvert
      .convertListNotNull<CafeteriaWindowItemResults>(json['results']);
  if (results != null) {
    cafeteriaWindowItemEntity.results = results;
  }
  return cafeteriaWindowItemEntity;
}

Map<String, dynamic> $CafeteriaWindowItemEntityToJson(
    CafeteriaWindowItemEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['results'] = entity.results.map((v) => v.toJson()).toList();
  return data;
}

CafeteriaWindowItemResults $CafeteriaWindowItemResultsFromJson(
    Map<String, dynamic> json) {
  final CafeteriaWindowItemResults cafeteriaWindowItemResults =
      CafeteriaWindowItemResults();
  final DateTime? updatedAt = jsonConvert.convert<DateTime>(json['updatedAt']);
  if (updatedAt != null) {
    cafeteriaWindowItemResults.updatedAt = updatedAt;
  }
  final String? place = jsonConvert.convert<String>(json['place']);
  if (place != null) {
    cafeteriaWindowItemResults.place = place;
  }
  final int? number = jsonConvert.convert<int>(json['number']);
  if (number != null) {
    cafeteriaWindowItemResults.number = number;
  }
  final String? unit = jsonConvert.convert<String>(json['unit']);
  if (unit != null) {
    cafeteriaWindowItemResults.unit = unit;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    cafeteriaWindowItemResults.name = name;
  }
  final String? objectId = jsonConvert.convert<String>(json['objectId']);
  if (objectId != null) {
    cafeteriaWindowItemResults.objectId = objectId;
  }
  final DateTime? createdAt = jsonConvert.convert<DateTime>(json['createdAt']);
  if (createdAt != null) {
    cafeteriaWindowItemResults.createdAt = createdAt;
  }
  final String? window = jsonConvert.convert<String>(json['window']);
  if (window != null) {
    cafeteriaWindowItemResults.window = window;
  }
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    cafeteriaWindowItemResults.status = status;
  }
  final List<int>? price = jsonConvert.convertListNotNull<int>(json['price']);
  if (price != null) {
    cafeteriaWindowItemResults.price = price;
  }
  final String? comment = jsonConvert.convert<String>(json['comment']);
  if (comment != null) {
    cafeteriaWindowItemResults.comment = comment;
  }
  final String? shopComment = jsonConvert.convert<String>(json['shopComment']);
  if (shopComment != null) {
    cafeteriaWindowItemResults.shopComment = shopComment;
  }
  return cafeteriaWindowItemResults;
}

Map<String, dynamic> $CafeteriaWindowItemResultsToJson(
    CafeteriaWindowItemResults entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['updatedAt'] = entity.updatedAt.toIso8601String();
  data['place'] = entity.place;
  data['number'] = entity.number;
  data['unit'] = entity.unit;
  data['name'] = entity.name;
  data['objectId'] = entity.objectId;
  data['createdAt'] = entity.createdAt.toIso8601String();
  data['window'] = entity.window;
  data['status'] = entity.status;
  data['price'] = entity.price;
  data['comment'] = entity.comment;
  data['shopComment'] = entity.shopComment;
  return data;
}
