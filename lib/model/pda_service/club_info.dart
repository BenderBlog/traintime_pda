// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:json_annotation/json_annotation.dart';

part 'club_info.g.dart';

enum ClubType {
  tech, // 技术社团
  acg, // Shining-ACG 社团部门专用
  union, // 有跟学校官方部门接触
  profit, // 可能涉及盈利，创业竞赛行为
  sport, // 运动社团
  art, // 思政，美术社团
  unknown, // 未知
}

@JsonSerializable(explicitToJson: true)
class ClubInfo {
  final String code;
  final String type;
  final String title;
  final String intro;
  final String description;
  final String qq;
  final int pic;

  ClubInfo({
    required this.code,
    required this.type,
    required this.title,
    required this.intro,
    required this.description,
    required this.qq,
    required this.pic,
  });

  List<ClubType> get typeList => type.split('|').map<ClubType>((value) {
        if (value == "tech") {
          return ClubType.tech;
        } else if (value == "acg")
          return ClubType.acg;
        else if (value == "union")
          return ClubType.union;
        else if (value == "profit")
          return ClubType.profit;
        else if (value == "sport")
          return ClubType.sport;
        else if (value == "art")
          return ClubType.art;
        else
          return ClubType.unknown;
      }).toList();

  factory ClubInfo.fromJson(Map<String, dynamic> json) =>
      _$ClubInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ClubInfoToJson(this);
}
