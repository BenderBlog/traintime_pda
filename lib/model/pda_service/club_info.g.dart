// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubInfo _$ClubInfoFromJson(Map<String, dynamic> json) => ClubInfo(
  code: json['code'] as String,
  type: toTypeList(json['type']),
  title: json['title'] as String,
  intro: json['intro'] as String,
  description: json['description'] as String,
  qq: qqFromJson(json['qq']),
  pic: (json['pic'] as num).toInt(),
  qqlink: json['qqlink'] as String,
  color: fromJsonToColor(json['color']),
);

Map<String, dynamic> _$ClubInfoToJson(ClubInfo instance) => <String, dynamic>{
  'code': instance.code,
  'type': instance.type.map((e) => _$ClubTypeEnumMap[e]!).toList(),
  'title': instance.title,
  'intro': instance.intro,
  'description': instance.description,
  'qq': instance.qq,
  'qqlink': instance.qqlink,
  'pic': instance.pic,
  'color': fromColorToJson(instance.color),
};

const _$ClubTypeEnumMap = {
  ClubType.tech: 'tech',
  ClubType.acg: 'acg',
  ClubType.union: 'union',
  ClubType.profit: 'profit',
  ClubType.sport: 'sport',
  ClubType.art: 'art',
  ClubType.game: 'game',
  ClubType.unknown: 'unknown',
};
