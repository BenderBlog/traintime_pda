// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';

class UserDefinedClassFile {
  static const userDefinedClassName = "UserClass.json";
  static File userDefinedClassFile = File(
    "${supportPath.path}/$userDefinedClassName",
  );

  /// New semenster, user defined class is useless.
  static void clearUserDefinedClass() {
    if (userDefinedClassFile.existsSync()) {
      userDefinedClassFile.deleteSync();
    }
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
    userDefinedClassFile.writeAsStringSync(jsonEncode(data.toJson()));
  }
}
