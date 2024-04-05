// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lost_and_found.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      json['nickname'] as String?,
      json['stu_name'] as String?,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'nickname': instance.nickname,
      'stu_name': instance.stu_name,
    };

LostAndFoundInfo _$LostAndFoundInfoFromJson(Map<String, dynamic> json) =>
    LostAndFoundInfo(
      json['title'] as String,
      json['category'] as String,
      json['position'] as String,
      json['ftime'] as String,
      json['ctime'] as String,
      json['dtime'] as String?,
      json['content'] as String,
      LostAndFoundInfo.parsePicture(json['picture']),
      json['contact'] as String,
      json['status'] as int,
      json['type'] as int,
      json['src'] as String?,
      json['wxpushnotice'] as int?,
      UserInfo.fromJson(json['user_info'] as Map<String, dynamic>),
      json['sms_record_id'] as int?,
    );

Map<String, dynamic> _$LostAndFoundInfoToJson(LostAndFoundInfo instance) =>
    <String, dynamic>{
      'title': instance.title,
      'category': instance.category,
      'position': instance.position,
      'ftime': instance.ftime,
      'ctime': instance.ctime,
      'dtime': instance.dtime,
      'content': instance.content,
      'picture': instance.picture,
      'contact': instance.contact,
      'status': instance.status,
      'type': instance.type,
      'src': instance.src,
      'wxpushnotice': instance.wxpushnotice,
      'user_info': instance.user_info.toJson(),
      'sms_record_id': instance.sms_record_id,
    };

LostAndFoundList _$LostAndFoundListFromJson(Map<String, dynamic> json) =>
    LostAndFoundList(
      json['code'] as int,
      json['count'] as int,
      json['page'] as String,
      (json['item_list'] as List<dynamic>)
          .map((e) => LostAndFoundInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LostAndFoundListToJson(LostAndFoundList instance) =>
    <String, dynamic>{
      'code': instance.code,
      'count': instance.count,
      'page': instance.page,
      'item_list': instance.item_list.map((e) => e.toJson()).toList(),
    };
