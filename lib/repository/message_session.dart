// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/message/message.dart';

RxList<NoticeMessage> messages = <NoticeMessage>[].obs;

Dio get dio => Dio()..interceptors.add(logDioAdapter);

const url = "https://legacy.superbart.top/traintime_pda_backend";

final messageLock = Lock(reentrant: false);

Future<void> checkMessage() => messageLock.synchronized(() async {
      var file = File("${supportPath.path}/Notice.json");
      bool isExist = await file.exists();
      List<NoticeMessage> toAdd = [];

      try {
        toAdd = await dio.get("$url/message.json").then(
              (value) => List<NoticeMessage>.generate(
                value.data.length,
                (index) => NoticeMessage.fromJson(value.data[index]),
              ),
            );
        file.writeAsStringSync(jsonEncode(toAdd));
      } catch (e) {
        if (isExist) {
          List data = jsonDecode(file.readAsStringSync());
          toAdd = List<NoticeMessage>.generate(
            data.length,
            (index) => NoticeMessage.fromJson(data[index]),
          );
        } else {
          toAdd = [];
        }
      }

      messages.clear();
      messages.addAll(toAdd);
      // Add cache.
    });
