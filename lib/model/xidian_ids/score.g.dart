// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Score _$ScoreFromJson(Map<String, dynamic> json) => Score(
  mark: (json['mark'] as num).toInt(),
  name: json['name'] as String,
  score: (json['score'] as num?)?.toDouble(),
  semesterCode: json['semesterCode'] as String,
  credit: (json['credit'] as num).toDouble(),
  classStatus: json['classStatus'] as String,
  isPassedStr: json['isPassedStr'] as String?,
  scoreTypeCode: (json['scoreTypeCode'] as num).toInt(),
  classType: json['classType'] as String,
  scoreStatus: json['scoreStatus'] as String,
  level: json['level'] as String?,
  classID: json['classID'] as String?,
);

Map<String, dynamic> _$ScoreToJson(Score instance) => <String, dynamic>{
  'mark': instance.mark,
  'name': instance.name,
  'score': instance.score,
  'semesterCode': instance.semesterCode,
  'credit': instance.credit,
  'classStatus': instance.classStatus,
  'classType': instance.classType,
  'scoreStatus': instance.scoreStatus,
  'scoreTypeCode': instance.scoreTypeCode,
  'level': instance.level,
  'isPassedStr': instance.isPassedStr,
  'classID': instance.classID,
};
