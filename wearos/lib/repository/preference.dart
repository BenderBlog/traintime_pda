// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// General user setting preference.

import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferencesWithCache prefs;

enum Preference {
  idsAccount(key: "idsAccount"),
  idsPassword(key: "idsPassword"),
  currentSemester(key: "currentSemester"),
  isUserDefinedSemester(key: "isUserDefinedSemester", type: "bool"),
  role(key: "role", type: "bool");

  const Preference({required this.key, this.type = "String"});

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

bool contains(Preference key) {
  return prefs.containsKey(key.key);
}

Future<void> setString(Preference key, String value) async {
  if (key.type != 'String') {
    throw WrongTypeException;
  }
  await prefs.setString(key.key, value);
  await prefs.reloadCache();
}

Future<void> setBool(Preference key, bool value) async {
  if (key.type != 'bool') {
    throw WrongTypeException;
  }
  await prefs.setBool(key.key, value);
  await prefs.reloadCache();
}

Future<void> remove(Preference key) async {
  await prefs.remove(key.key);
  await prefs.reloadCache();
}

class WrongTypeException implements Exception {}
