import 'package:json_annotation/json_annotation.dart';

part 'creative.g.dart';

@JsonSerializable()
class Project {
  final String name;
  final String description;
  final String type;
  final String status;
  final String college;
  final int limit;
  final bool isPublic;
  final int captainID;
  final int id;
  final DateTime? createAt;
  final DateTime? updatedAt;

  const Project({
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.college,
    required this.limit,
    required this.isPublic,
    required this.captainID,
    required this.id,
    required this.createAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Job {
  final String name;
  final String skill;
  final List<String> tags;
  final String progress;
  final String description;
  final String reward;
  final DateTime endTime;
  final int exceptNumber;
  final int acceptedNumber;
  final int projectID;
  final Project project;
  final int id;
  final DateTime? createAt;
  final DateTime? updatedAt;

  const Job({
    required this.name,
    required this.description,
    required this.skill,
    required this.tags,
    required this.progress,
    required this.reward,
    required this.endTime,
    required this.exceptNumber,
    required this.acceptedNumber,
    required this.projectID,
    required this.project,
    required this.id,
    required this.createAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);
}
