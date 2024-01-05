// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creative.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      college: json['college'] as String,
      limit: json['limit'] as int,
      isPublic: json['isPublic'] as bool,
      captainID: json['captainID'] as int,
      id: json['id'] as int,
      createAt: json['createAt'] == null
          ? null
          : DateTime.parse(json['createAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'status': instance.status,
      'college': instance.college,
      'limit': instance.limit,
      'isPublic': instance.isPublic,
      'captainID': instance.captainID,
      'id': instance.id,
      'createAt': instance.createAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      name: json['name'] as String,
      description: json['description'] as String,
      skill: json['skill'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      progress: json['progress'] as String,
      reward: json['reward'] as String,
      endTime: DateTime.parse(json['endTime'] as String),
      exceptNumber: json['exceptNumber'] as int,
      acceptedNumber: json['acceptedNumber'] as int,
      projectID: json['projectID'] as int,
      project: Project.fromJson(json['project'] as Map<String, dynamic>),
      id: json['id'] as int,
      createAt: json['createAt'] == null
          ? null
          : DateTime.parse(json['createAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'name': instance.name,
      'skill': instance.skill,
      'tags': instance.tags,
      'progress': instance.progress,
      'description': instance.description,
      'reward': instance.reward,
      'endTime': instance.endTime.toIso8601String(),
      'exceptNumber': instance.exceptNumber,
      'acceptedNumber': instance.acceptedNumber,
      'projectID': instance.projectID,
      'project': instance.project,
      'id': instance.id,
      'createAt': instance.createAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
