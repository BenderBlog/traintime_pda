// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as pref;

class UserDefinedClassFile {
  static const userDefinedClassName = "UserClass.json";
  static File userDefinedClassFile = File(
    "${supportPath.path}/$userDefinedClassName",
  );

  static Future<void> _syncToGroup(String data) async {
    if (!Platform.isIOS) return;
    final api = SaveToGroupIdSwiftApi();
    try {
      final result = await api.saveToGroupId(
        FileToGroupID(
          appid: pref.appId,
          fileName: userDefinedClassName,
          data: data,
        ),
      );
      log.info(
        "[UserDefinedClassFile][_syncToGroup] "
        "ios Save to public place status: $result.",
      );
    } catch (e, s) {
      log.handle(e, s);
    }
  }

  /// New semenster, user defined class is useless.
  static void clearUserDefinedClass() {
    if (userDefinedClassFile.existsSync()) {
      userDefinedClassFile.deleteSync();
    }
    unawaited(_syncToGroup(jsonEncode(UserDefinedClassData.empty().toJson())));
  }

  static UserDefinedClassData getUserDefinedClass() {
    bool userDefinedFileIsExist = userDefinedClassFile.existsSync();
    if (!userDefinedFileIsExist) {
      userDefinedClassFile.writeAsStringSync(
        jsonEncode(UserDefinedClassData.empty()),
      );
      return UserDefinedClassData.empty();
    }
    try {
      return UserDefinedClassData.fromJson(
        jsonDecode(userDefinedClassFile.readAsStringSync()),
      );
    } catch (e, s) {
      log.handle(
        e,
        s,
        "[UserDefinedClassInfo][getUserDefinedClass] Have issue, data will be cleard.",
      );
      userDefinedClassFile.deleteSync();
      userDefinedClassFile.writeAsStringSync(
        jsonEncode(UserDefinedClassData.empty()),
      );
      return UserDefinedClassData.empty();
    }
  }

  static void updateUserDefinedClass(UserDefinedClassData data) {
    final json = jsonEncode(data.toJson());
    userDefinedClassFile.writeAsStringSync(json);
    unawaited(_syncToGroup(json));
  }
}
