// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Creative School Service Response Model, related to Jichuang Studio
// Remove the useless func, but model will be saved...
/*
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
  final List<String>? tags;
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
    this.tags,
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

const skill = {
  "技术类": [
    "前端开发",
    "后端开发",
    "APP 开发",
    "游戏开发",
    "AI 研发",
    "硬件开发",
    "数据工程师",
    "数据分析与挖掘",
    "运维工程师",
    "测试工程师",
    "其他开发",
  ],
  "项目包装类": [
    "文案策划",
    "PPT 美工",
    "视频制作",
    "BP 设计",
    "答辩",
  ],
  "市场职能类": [
    "活动策划",
    "新媒体运营",
    "商业分析及财报预测",
    "财务",
    "市场调研",
    "需求与政策调研",
    "其他市场职能",
  ],
  "产品类": [
    "UI 设计",
    "交互设计",
    "产品经理",
    "内容策划",
    "互联网产品运营",
    "游戏策划",
    "其他产品类",
  ],
  "其他": [
    "其他",
  ],
};
*/
