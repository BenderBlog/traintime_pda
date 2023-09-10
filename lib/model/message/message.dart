// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateMessage {
  final String code;
  final List<String> change;
  final String ioslink;
  final String github;

  UpdateMessage({
    required this.code,
    required this.change,
    required this.ioslink,
    required this.github,
  });

  factory UpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$UpdateMessageFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMessageToJson(this);
}

/*
[
{
  "title": "2023-2024 校历",
  "message": "https://mp.weixin.qq.com/s/L_jXTqYC5DzzkgQQUDI6MQ",
  "isLink": "true",
  "type": "学校"
},
{
  "title": "欢迎使用本应用",
  "message": "欢迎使用 XDYou / TraintimePDA！如有问题可加群 902652582。",
  "isLink": "false",
  "type": "应用"
},
{
  "title": "西电 MSC 社团 2023 招新",
  "message": "https://qm.qq.com/cgi-bin/qm/qr?authKey=R37Jnhwbu8x9i4BP3Kb4ckt1kn40u%2BPFczFozmt%2FpUAx0jQ2yWMXEnRZS7u1M4wF&k=2P8icnQ3m_-V9h2X0YemFEis6Cbl09uT&noverify=0",
  "isLink": "false",
  "type": "社团"
}
]
*/
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
