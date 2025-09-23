// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:result_dart/functions.dart';
import 'package:result_dart/result_dart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/pda_service/message.dart';
import 'package:watermeter/repository/preference.dart' as pref;

Rx<UpdateMessage?> updateMessage = Rx<UpdateMessage?>(null);
RxList<ClubInfo> clubList = <ClubInfo>[].obs;
Rx<SessionState> clubState = SessionState.none.obs;
Rx<Object?> clubError = null.obs;

Dio get dio => Dio()..interceptors.add(logDioAdapter);

const url = "https://legacy.superbart.top/traintime_pda_backend";

final messageLock = Lock(reentrant: false);
final updateLock = Lock(reentrant: false);
final clubLock = Lock(reentrant: false);

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
    for (int i = 0; i < math.min(versionCode.length, localCode.length); i++) {
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
  clubError.value == null;

  return dio
      .get("$url/club.json")
      .then((data) {
        clubList.clear();
        try {
          for (var i in data.data) {
            clubList.add(ClubInfo.fromJson(i));
          }
          clubState.value = SessionState.fetched;
        } catch (e, s) {
          log.error("[getClubList] Error occured!", e, s);
          clubError.value = e;
          clubState.value = SessionState.error;
        }
      })
      .onError((e, s) {
        log.error("[getClubList] Error occured!", e, s);
        clubError.value = e.toString();
        clubState.value = SessionState.error;
      });
});

Future<String> getClubArticle(String code) => clubLock.synchronized<String>(
  () => dio
      .get("$url/club_introduction/$code/index.html")
      .then(
        (value) => (value.data as String).replaceAll(
          "<img src=\"",
          "<img src=\"$url/club_introduction/$code/",
        ),
      ),
);

String getClubAvatar(String code) => "$url/poster/$code.jpg";

String getClubImage(String code, int index) => "$url/poster/$code-$index.jpg";

Future<ResultDart<ClubInfo, Exception>> getClubInfo(String code) async {
  try {
    var data = await dio.get("$url/club.json").then((value) => value.data);
    return (data as List<dynamic>)
        .map<ClubInfo>((value) => ClubInfo.fromJson(value))
        .toList()
        .firstWhere((value) => value.code == code)
        .toSuccess();
  } on Exception catch (e, s) {
    log.error("[getClubInfo] Error occured!", e, s);
    return failureOf(e);
  } catch (e, s) {
    log.error("[getClubInfo] Error occured!", e, s);
    return failureOf(Exception(e.toString()));
  }
}
