// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/pda_service/message.dart';
import 'package:watermeter/repository/preference.dart' as pref;

RxList<NoticeMessage> messages = <NoticeMessage>[].obs;
Rx<UpdateMessage?> updateMessage = Rx<UpdateMessage?>(null);
RxList<ClubInfo> clubList = <ClubInfo>[].obs;
Rx<SessionState> clubState = SessionState.none.obs;

Dio get dio => Dio()..interceptors.add(logDioAdapter);

const url = "https://legacy.superbart.top/traintime_pda_backend";

final messageLock = Lock(reentrant: false);
final updateLock = Lock(reentrant: false);
final clubLock = Lock(reentrant: false);

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

Future<bool?> checkUpdate() => updateLock.synchronized<bool?>(() async {
      updateMessage.value = null;
      return dio.get("$url/version.json").then((data) {
        updateMessage.value = UpdateMessage.fromJson(data.data);
        List<int> versionCode = updateMessage.value!.code
            .split('.')
            .map((value) => int.parse(value))
            .toList();
        List<int> localCode = pref.packageInfo.version
            .split('.')
            .map((value) => int.parse(value))
            .toList();
        bool? isNewAvaliable = false;
        for (int i = 0;
            i < math.min(versionCode.length, localCode.length);
            i++) {
          if (versionCode[i] > localCode[i]) {
            isNewAvaliable = true;
            break;
          } else if (versionCode[i] < localCode[i]) {
            isNewAvaliable = null;
            break;
          }
        }
        return isNewAvaliable;
      });
    });

Future<void> getClubList() => clubLock.synchronized(() async {
      clubState.value = SessionState.fetching;
      return dio.get("$url/club.json").then((data) {
        clubList.clear();
        try {
          for (var i in data.data) {
            clubList.add(ClubInfo.fromJson(i));
          }
          clubState.value = SessionState.fetched;
        } catch (e, s) {
          log.error("[getClubList] Error occured!", e, s);
          clubState.value = SessionState.error;
        }
      });
    });

String getClubAvatar(String code) => "$url/poster/$code.jpg";

String getClubImage(String code, int index) => "$url/poster/$code-$index.jpg";
