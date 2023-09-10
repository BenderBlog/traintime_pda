// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/message/message.dart';

class MessageSession extends NetworkSession {
  final url = "https://legacy.superbart.xyz/traintime_pda_backend";
  Future<UpdateMessage> checkUpdate() async {
    return await dio.get("$url/version.json").then(
          (value) => UpdateMessage.fromJson(value.data),
        );
  }

  Future<List<NoticeMessage>> checkMessage() async {
    return await dio.get("$url/message.json").then(
          (value) => List<NoticeMessage>.generate(
            value.data.length,
            (index) => NoticeMessage.fromJson(value.data[index]),
          ),
        );
  }
}
