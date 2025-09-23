// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMessage _$UpdateMessageFromJson(Map<String, dynamic> json) =>
    UpdateMessage(
      code: json['code'] as String,
      update: (json['update'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ioslink: json['ioslink'] as String,
      github: json['github'] as String,
      fdroid: json['fdroid'] as String,
    );

Map<String, dynamic> _$UpdateMessageToJson(UpdateMessage instance) =>
    <String, dynamic>{
      'code': instance.code,
      'update': instance.update,
      'ioslink': instance.ioslink,
      'github': instance.github,
      'fdroid': instance.fdroid,
    };
