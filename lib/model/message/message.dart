// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateMessage {
  final String code;
  final List<String> update;
  final String ioslink;
  final String github;
  final String fdroid;

  UpdateMessage({
    required this.code,
    required this.update,
    required this.ioslink,
    required this.github,
    required this.fdroid,
  });

  factory UpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$UpdateMessageFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NoticeMessage {
  final String title;
  final String message;
  final String isLink;
  final String type;

  NoticeMessage({
    required this.title,
    required this.message,
    required this.isLink,
    required this.type,
  });

  factory NoticeMessage.fromJson(Map<String, dynamic> json) =>
      _$NoticeMessageFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeMessageToJson(this);
}
