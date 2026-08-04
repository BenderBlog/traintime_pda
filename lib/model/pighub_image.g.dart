// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pighub_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PigHubImage _$PigHubImageFromJson(Map<String, dynamic> json) => PigHubImage(
  id: (json['id'] as num).toInt(),
  imageUrl: json['image_url'] as String,
  title: json['title'] as String,
  viewCount: (json['view_count'] as num).toInt(),
);

Map<String, dynamic> _$PigHubImageToJson(PigHubImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_url': instance.imageUrl,
      'title': instance.title,
      'view_count': instance.viewCount,
    };
