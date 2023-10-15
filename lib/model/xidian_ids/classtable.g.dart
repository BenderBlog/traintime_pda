// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classtable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassDetail _$ClassDetailFromJson(Map<String, dynamic> json) => ClassDetail(
      name: json['name'] as String,
      teacher: json['teacher'] as String?,
      code: json['code'] as String?,
      number: json['number'] as String?,
    );

Map<String, dynamic> _$ClassDetailToJson(ClassDetail instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacher': instance.teacher,
      'code': instance.code,
      'number': instance.number,
    };

TimeArrangement _$TimeArrangementFromJson(Map<String, dynamic> json) =>
    TimeArrangement(
      index: json['index'] as int,
      weekList: json['week_list'] as String,
      classroom: json['classroom'] as String?,
      day: json['day'] as int,
      start: json['start'] as int,
      stop: json['stop'] as int,
    );

Map<String, dynamic> _$TimeArrangementToJson(TimeArrangement instance) {
  final val = <String, dynamic>{
    'index': instance.index,
    'week_list': instance.weekList,
    'day': instance.day,
    'start': instance.start,
    'stop': instance.stop,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('classroom', instance.classroom);
  return val;
}

ClassTableData _$ClassTableDataFromJson(Map<String, dynamic> json) =>
    ClassTableData(
      semesterLength: json['semesterLength'] as int? ?? 1,
      semesterCode: json['semesterCode'] as String? ?? "",
      termStartDay: json['termStartDay'] as String? ?? "",
      classDetail: (json['classDetail'] as List<dynamic>?)
          ?.map((e) => ClassDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      notArranged: (json['notArranged'] as List<dynamic>?)
          ?.map((e) => ClassDetail.fromJson(e as Map<String, dynamic>))
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
      originalAffectedWeeks: json['originalAffectedWeeks'] as String,
      newAffectedWeeks: json['newAffectedWeeks'] as String?,
      originalTeacher: json['originalTeacher'] as String?,
      newTeacher: json['newTeacher'] as String?,
      originalClassRange: (json['originalClassRange'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      newClassRange: (json['newClassRange'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      originalWeek: json['originalWeek'] as int,
      newWeek: json['newWeek'] as int?,
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
      'originalTeacher': instance.originalTeacher,
      'newTeacher': instance.newTeacher,
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
