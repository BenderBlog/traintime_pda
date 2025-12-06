// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassAttendanceDetail _$ClassAttendanceDetailFromJson(
  Map<String, dynamic> json,
) => ClassAttendanceDetail(
  submittime: json['submittime'] as String?,
  createxxuid: json['createxxuid'] as String,
  userStatus: (json['userStatus'] as num?)?.toInt(),
  creatorName: json['creatorName'] as String,
  activeid: (json['activeid'] as num).toInt(),
  starttime: json['starttime'] as String,
  attendid: (json['attendid'] as num?)?.toInt(),
  activeType: (json['activeType'] as num).toInt(),
  name: json['name'] as String?,
  otherId: (json['other_id'] as num).toInt(),
  updatetime: (json['updatetime'] as num?)?.toInt(),
  createUid: json['createUid'] as String,
  status: (json['status'] as num).toInt(),
);

Map<String, dynamic> _$ClassAttendanceDetailToJson(
  ClassAttendanceDetail instance,
) => <String, dynamic>{
  'submittime': instance.submittime,
  'createxxuid': instance.createxxuid,
  'userStatus': instance.userStatus,
  'creatorName': instance.creatorName,
  'activeid': instance.activeid,
  'starttime': instance.starttime,
  'attendid': instance.attendid,
  'activeType': instance.activeType,
  'name': instance.name,
  'other_id': instance.otherId,
  'updatetime': instance.updatetime,
  'createUid': instance.createUid,
  'status': instance.status,
};
