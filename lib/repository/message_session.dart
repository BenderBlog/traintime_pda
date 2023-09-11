// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/controller/message_observer.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/message/message.dart';

class MessageSession extends NetworkSession {
  @override
  Dio get dio => Dio()..interceptors.add(alice.getDioInterceptor());

  final url = "https://legacy.superbart.xyz/traintime_pda_backend";

  Future<UpdateMessage> checkUpdate() async {
    return await dio.get("$url/version.json").then(
          (value) => UpdateMessage.fromJson(value.data),
        );
  }

  Future<void> checkMessage() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    if (!await appDocDir.exists()) {
      await appDocDir.create();
    }
    var file = File("${appDocDir.path}/Notice.json");
    bool isExist = file.existsSync();
    List<NoticeMessage> toAdd = [];

    try {
      toAdd = await dio.get("$url/message.json").then(
            (value) => List<NoticeMessage>.generate(
              value.data.length,
              (index) => NoticeMessage.fromJson(value.data[index]),
            ),
          );
      file.writeAsStringSync(jsonEncode(toAdd));
    } on Exception {
      if (isExist) {
        toAdd = jsonDecode(file.readAsStringSync());
      } else {
        toAdd = [];
      }
    }

    messages.clear();
    messages.addAll(toAdd);
    // Add cache.
  }
}
