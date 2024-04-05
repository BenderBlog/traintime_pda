// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'lost_and_found.g.dart';

@JsonSerializable(explicitToJson: true)
class UserInfo {
  final String? nickname;
  final String? stu_name;
  const UserInfo(
    this.nickname,
    this.stu_name,
  );

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LostAndFoundInfo {
  final String title;
  final String category;
  final String position;
  final String ftime;
  final String ctime;
  final String? dtime;
  final String content;
  final List<String> picture;
  final String contact;
  final int status;
  final int type;
  final String? src;
  final int? wxpushnotice;
  final UserInfo user_info;
  final int? sms_record_id;

  static List<String> parsePicture(dynamic data) {
    if (data.toString().isEmpty) {
      return [];
    } else {
      return (data as List<dynamic>).map((e) => e as String).toList();
    }
  }

  const LostAndFoundInfo(
    this.title,
    this.category,
    this.position,
    this.ftime,
    this.ctime,
    this.dtime,
    this.content,
    this.picture,
    this.contact,
    this.status,
    this.type,
    this.src,
    this.wxpushnotice,
    this.user_info,
    this.sms_record_id,
  );

  String get getType {
    if (type == 1) {
      return "丢失物品";
    } else if (type == 2) {
      return "捡到物品";
    } else {
      return "";
    }
  }

  factory LostAndFoundInfo.fromJson(Map<String, dynamic> json) =>
      _$LostAndFoundInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LostAndFoundInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LostAndFoundList {
  final int code;
  final int count;
  final String page;
  final List<LostAndFoundInfo> item_list;

  const LostAndFoundList(
    this.code,
    this.count,
    this.page,
    this.item_list,
  );

  factory LostAndFoundList.fromJson(Map<String, dynamic> json) =>
      _$LostAndFoundListFromJson(json);

  Map<String, dynamic> toJson() => _$LostAndFoundListToJson(this);
}
