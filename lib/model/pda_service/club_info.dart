// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:watermeter/repository/pda_service_session.dart';

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

String qqFromJson(data) => data.toString();

@JsonSerializable(explicitToJson: true)
class ClubInfo {
  final String code;
  final String type;
  final String title;
  final String intro;
  final String description;
  @JsonKey(name: "qq", fromJson: qqFromJson)
  final String qq;
  final String qqlink;
  final int pic;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ImageProvider icon;

  ClubInfo({
    required this.code,
    required this.type,
    required this.title,
    required this.intro,
    required this.description,
    required this.qq,
    required this.pic,
    required this.qqlink,
  }) : icon = NetworkImage(getClubAvatar(code));

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
