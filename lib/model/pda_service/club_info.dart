// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
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
  game, // 游戏社团
  unknown, // 未知
  all, // 所有
}

String qqFromJson(data) => data.toString();

List<ClubType> toTypeList(type) =>
    type.toString().split('|').map<ClubType>((value) {
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
      else if (value == "game")
        return ClubType.game;
      else
        return ClubType.unknown;
    }).toList();

Color fromJsonToColor(color) {
  String value = color.toString();
  if (value == "red") {
    return Colors.red;
  } else if (value == "pink")
    return Colors.pink;
  else if (value == "purple")
    return Colors.purple;
  else if (value == "deepPurple")
    return Colors.deepPurple;
  else if (value == "indigo")
    return Colors.indigo;
  else if (value == "blue")
    return Colors.blue;
  else if (value == "lightBlue")
    return Colors.lightBlue;
  else if (value == "cyan")
    return Colors.cyan;
  else if (value == "teal")
    return Colors.teal;
  else if (value == "green")
    return Colors.green;
  else if (value == "lightGreen")
    return Colors.lightGreen;
  else if (value == "lime")
    return Colors.lime;
  else if (value == "yellow")
    return Colors.yellow;
  else if (value == "amber")
    return Colors.amber;
  else if (value == "orange")
    return Colors.orange;
  else if (value == "deepOrange")
    return Colors.deepOrange;
  else if (value == "brown")
    return Colors.brown;
  else
    return Colors.deepPurple;
}

String fromColorToJson(Color value) {
  if (value == Colors.red) {
    return "red";
  } else if (value == Colors.pink)
    return "pink";
  else if (value == Colors.purple)
    return "purple";
  else if (value == Colors.deepPurple)
    return "deepPurple";
  else if (value == Colors.indigo)
    return "indigo";
  else if (value == Colors.blue)
    return "blue";
  else if (value == Colors.lightBlue)
    return "lightBlue";
  else if (value == Colors.cyan)
    return "cyan";
  else if (value == Colors.teal)
    return "teal";
  else if (value == Colors.green)
    return "green";
  else if (value == Colors.lightGreen)
    return "lightGreen";
  else if (value == Colors.lime)
    return "lime";
  else if (value == Colors.yellow)
    return "yellow";
  else if (value == Colors.amber)
    return "amber";
  else if (value == Colors.orange)
    return "orange";
  else if (value == Colors.deepOrange)
    return "deepOrange";
  else if (value == Colors.brown)
    return "brown";
  else
    return "deepPurple";
}

@JsonSerializable(explicitToJson: true)
class ClubInfo {
  final String code;
  @JsonKey(name: "type", fromJson: toTypeList)
  final List<ClubType> type;
  final String title;
  final String intro;
  final String description;
  @JsonKey(name: "qq", fromJson: qqFromJson)
  final String qq;
  final String qqlink;
  final int pic;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ImageProvider icon;
  @JsonKey(name: "color", fromJson: fromJsonToColor, toJson: fromColorToJson)
  final Color color;

  ClubInfo({
    required this.code,
    required this.type,
    required this.title,
    required this.intro,
    required this.description,
    required this.qq,
    required this.pic,
    required this.qqlink,
    required this.color,
  }) : icon = NetworkImage(getClubAvatar(code));

  factory ClubInfo.fromJson(Map<String, dynamic> json) =>
      _$ClubInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ClubInfoToJson(this);
}
