// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentData _$ExperimentDataFromJson(Map<String, dynamic> json) =>
    ExperimentData(
      type: $enumDecode(_$ExperimentTypeEnumMap, json['type']),
      name: json['name'] as String,
      classroom: json['classroom'] as String,
      timeRanges: (json['timeRanges'] as List<dynamic>)
          .map(
            (e) => _$recordConvert(
              e,
              ($jsonValue) => (
                DateTime.parse($jsonValue[r'$1'] as String),
                DateTime.parse($jsonValue[r'$2'] as String),
              ),
            ),
          )
          .toList(),
      teacher: json['teacher'] as String,
      reference: json['reference'] as String?,
    );

Map<String, dynamic> _$ExperimentDataToJson(ExperimentData instance) =>
    <String, dynamic>{
      'type': _$ExperimentTypeEnumMap[instance.type]!,
      'name': instance.name,
      'classroom': instance.classroom,
      'timeRanges': instance.timeRanges
          .map(
            (e) => <String, dynamic>{
              r'$1': e.$1.toIso8601String(),
              r'$2': e.$2.toIso8601String(),
            },
          )
          .toList(),
      'teacher': instance.teacher,
      'reference': instance.reference,
    };

const _$ExperimentTypeEnumMap = {ExperimentType.others: 'others'};

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);
