/*
General user preference. 
Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;
late PackageInfo packageInfo;

enum Preference {
  name(key: "name", type: "String"),
  sex(key: "sex", type: "String"),
  execution(key: "execution", type: "String"), // 书院
  institutes(key: "institutes", type: "String"), // 学院
  subject(key: "subject", type: "String"), // 专业
  dorm(key: "dorm", type: "String"), // 宿舍
  idsAccount(key: "idsAccount", type: "String"), // 一站式帐号
  idsPassword(key: "idsPassword", type: "String"), // 一站式密码
  sportPassword(key: "sportPassword", type: "String"), // 体适能密码
  electricityPassword(key: "electricityPassword", type: "String"), // 电费密码
  decorated(key: "decorated", type: "bool"), // 课表是否开启背景
  decoration(key: "decoration", type: "bool"), // 背景图是否设置
  swift(key: "swift", type: "int"), // 周次偏移
  color(key: "color", type: "int"), // 颜色索引
  currentSemester(key: "currentSemester", type: "String"), // 当前学期编码
  currentStartDay(key: "currentStartDay", type: "String"); // 当前学期编码

  const Preference({required this.key, this.type = "String"});
  factory Preference.fromKey(String key) {
    return values.firstWhere((e) => e.key == key);
  }

  final String key;
  final String type;
}

String getString(Preference key) {
  if (key.type != 'String') {
    throw WrongTypeException;
  }
  return prefs.getString(key.key) ?? "";
}

bool getBool(Preference key) {
  if (key.type != 'bool') {
    throw WrongTypeException;
  }
  return prefs.getBool(key.key) ?? false;
}

int getInt(Preference key) {
  if (key.type != 'int') {
    throw WrongTypeException;
  }
  return prefs.getInt(key.key) ?? 0;
}

void setString(Preference key, String value) {
  if (key.type != 'String') {
    throw WrongTypeException;
  }
  prefs.setString(key.key, value);
  prefs.reload();
}

void setBool(Preference key, bool value) {
  if (key.type != 'bool') {
    throw WrongTypeException;
  }
  prefs.setBool(key.key, value);
  prefs.reload();
}

void setInt(Preference key, int value) {
  if (key.type != 'int') {
    throw WrongTypeException;
  }
  prefs.setInt(key.key, value);
  prefs.reload();
}

void prefrenceClear() {
  prefs.clear();
  prefs.reload();
}

class NotRegisteredException implements Exception {}

class NotFoundException implements Exception {}

class WrongTypeException implements Exception {}
