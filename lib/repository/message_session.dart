// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/message/message.dart';

RxList<NoticeMessage> messages = <NoticeMessage>[].obs;

Dio get dio => Dio()..interceptors.add(aliceDioAdapter);

const url = "https://legacy.superbart.top/traintime_pda_backend";

// Never used lol...
Future<UpdateMessage> checkUpdate() async {
  return await dio.get("$url/version.json").then(
        (value) => UpdateMessage.fromJson(value.data),
      );
}

Future<void> checkMessage() async {
  var file = File("${supportPath.path}/Notice.json");
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
