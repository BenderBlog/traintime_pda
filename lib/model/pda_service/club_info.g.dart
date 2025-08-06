// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubInfo _$ClubInfoFromJson(Map<String, dynamic> json) => ClubInfo(
      code: json['code'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      intro: json['intro'] as String,
      description: json['description'] as String,
      qq: qqFromJson(json['qq']),
      pic: (json['pic'] as num).toInt(),
      qqlink: json['qqlink'] as String,
    );

Map<String, dynamic> _$ClubInfoToJson(ClubInfo instance) => <String, dynamic>{
      'code': instance.code,
      'type': instance.type,
      'title': instance.title,
      'intro': instance.intro,
      'description': instance.description,
      'qq': instance.qq,
      'qqlink': instance.qqlink,
      'pic': instance.pic,
    };
