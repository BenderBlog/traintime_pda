// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classtable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotArrangementClassDetail _$NotArrangementClassDetailFromJson(
        Map<String, dynamic> json) =>
    NotArrangementClassDetail(
      name: json['name'] as String,
      code: json['code'] as String?,
      number: json['number'] as String?,
      teacher: json['teacher'] as String?,
    );

Map<String, dynamic> _$NotArrangementClassDetailToJson(
        NotArrangementClassDetail instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'number': instance.number,
      'teacher': instance.teacher,
    };

ClassDetail _$ClassDetailFromJson(Map<String, dynamic> json) => ClassDetail(
      name: json['name'] as String,
      code: json['code'] as String?,
      number: json['number'] as String?,
    );

Map<String, dynamic> _$ClassDetailToJson(ClassDetail instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'number': instance.number,
    };

TimeArrangement _$TimeArrangementFromJson(Map<String, dynamic> json) =>
    TimeArrangement(
      source: $enumDecode(_$SourceEnumMap, json['source']),
      index: (json['index'] as num).toInt(),
      weekList:
          (json['week_list'] as List<dynamic>).map((e) => e as bool).toList(),
      classroom: json['classroom'] as String?,
      teacher: json['teacher'] as String?,
      day: (json['day'] as num).toInt(),
      start: (json['start'] as num).toInt(),
      stop: (json['stop'] as num).toInt(),
    );

Map<String, dynamic> _$TimeArrangementToJson(TimeArrangement instance) {
  final val = <String, dynamic>{
    'index': instance.index,
    'week_list': instance.weekList,
    'teacher': instance.teacher,
    'day': instance.day,
    'start': instance.start,
    'stop': instance.stop,
    'source': _$SourceEnumMap[instance.source]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('classroom', instance.classroom);
  return val;
}

const _$SourceEnumMap = {
  Source.empty: 'empty',
  Source.school: 'school',
  Source.user: 'user',
};

ClassTableData _$ClassTableDataFromJson(Map<String, dynamic> json) =>
    ClassTableData(
      semesterLength: (json['semesterLength'] as num?)?.toInt() ?? 1,
      semesterCode: json['semesterCode'] as String? ?? "",
      termStartDay: json['termStartDay'] as String? ?? "",
      classDetail: (json['classDetail'] as List<dynamic>?)
          ?.map((e) => ClassDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      userDefinedDetail: (json['userDefinedDetail'] as List<dynamic>?)
          ?.map((e) => ClassDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      notArranged: (json['notArranged'] as List<dynamic>?)
          ?.map((e) =>
              NotArrangementClassDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeArrangement: (json['timeArrangement'] as List<dynamic>?)
          ?.map((e) => TimeArrangement.fromJson(e as Map<String, dynamic>))
          .toList(),
      classChanges: (json['classChanges'] as List<dynamic>?)
          ?.map((e) => ClassChange.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassTableDataToJson(ClassTableData instance) =>
    <String, dynamic>{
      'semesterLength': instance.semesterLength,
      'semesterCode': instance.semesterCode,
      'termStartDay': instance.termStartDay,
      'classDetail': instance.classDetail.map((e) => e.toJson()).toList(),
      'userDefinedDetail':
          instance.userDefinedDetail.map((e) => e.toJson()).toList(),
      'notArranged': instance.notArranged.map((e) => e.toJson()).toList(),
      'timeArrangement':
          instance.timeArrangement.map((e) => e.toJson()).toList(),
      'classChanges': instance.classChanges.map((e) => e.toJson()).toList(),
    };

ClassChange _$ClassChangeFromJson(Map<String, dynamic> json) => ClassChange(
      type: $enumDecode(_$ChangeTypeEnumMap, json['type']),
      classCode: json['classCode'] as String,
      classNumber: json['classNumber'] as String,
      className: json['className'] as String,
      originalAffectedWeeks: (json['originalAffectedWeeks'] as List<dynamic>?)
          ?.map((e) => e as bool)
          .toList(),
      newAffectedWeeks: (json['newAffectedWeeks'] as List<dynamic>?)
          ?.map((e) => e as bool)
          .toList(),
      originalTeacherData: json['originalTeacherData'] as String?,
      newTeacherData: json['newTeacherData'] as String?,
      originalClassRange: (json['originalClassRange'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      newClassRange: (json['newClassRange'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      originalWeek: (json['originalWeek'] as num?)?.toInt(),
      newWeek: (json['newWeek'] as num?)?.toInt(),
      originalClassroom: json['originalClassroom'] as String?,
      newClassroom: json['newClassroom'] as String?,
    );

Map<String, dynamic> _$ClassChangeToJson(ClassChange instance) =>
    <String, dynamic>{
      'type': _$ChangeTypeEnumMap[instance.type]!,
      'classCode': instance.classCode,
      'classNumber': instance.classNumber,
      'className': instance.className,
      'originalAffectedWeeks': instance.originalAffectedWeeks,
      'newAffectedWeeks': instance.newAffectedWeeks,
      'originalTeacherData': instance.originalTeacherData,
      'newTeacherData': instance.newTeacherData,
      'originalClassRange': instance.originalClassRange,
      'newClassRange': instance.newClassRange,
      'originalWeek': instance.originalWeek,
      'newWeek': instance.newWeek,
      'originalClassroom': instance.originalClassroom,
      'newClassroom': instance.newClassroom,
    };

const _$ChangeTypeEnumMap = {
  ChangeType.change: 'change',
  ChangeType.stop: 'stop',
  ChangeType.patch: 'patch',
};

UserDefinedClassData _$UserDefinedClassDataFromJson(
        Map<String, dynamic> json) =>
    UserDefinedClassData(
      userDefinedDetail: (json['userDefinedDetail'] as List<dynamic>)
          .map((e) => ClassDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeArrangement: (json['timeArrangement'] as List<dynamic>)
          .map((e) => TimeArrangement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserDefinedClassDataToJson(
        UserDefinedClassData instance) =>
    <String, dynamic>{
      'userDefinedDetail':
          instance.userDefinedDetail.map((e) => e.toJson()).toList(),
      'timeArrangement':
          instance.timeArrangement.map((e) => e.toJson()).toList(),
    };
