// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:shared_preferences/shared_preferences.dart';

/// 用户设置与认证状态管理
/// 假设程序仅在校内网运行
///
/// 使用主程序传入的 [SharedPreferencesWithCache] 实例，
/// 与程序整体共享同一个持久化存储。
class SettingsService {
  static const _keyUid = 'ruisi_uid';
  static const _keyUsername = 'ruisi_username';
  static const _keyFormhash = 'ruisi_formhash';
  static const _keyPassword = 'ruisi_password';

  final SharedPreferencesWithCache _prefs;

  int? _uid;
  String? _username;
  String? _formhash;
  String? _password;

  int? get uid => _uid;
  String? get username => _username;
  String? get formhash => _formhash;
  String? get password => _password;
  bool get isLogin => _uid != null;

  SettingsService(this._prefs) {
    _uid = _prefs.getInt(_keyUid);
    _username = _prefs.getString(_keyUsername);
    _formhash = _prefs.getString(_keyFormhash);
    _password = _prefs.getString(_keyPassword);
  }

  Future<void> saveLogin({
    required int uid,
    required String username,
    required String formhash,
    String? password,
  }) async {
    _uid = uid;
    _username = username;
    _formhash = formhash;
    _password = password;
    await _prefs.setInt(_keyUid, uid);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyFormhash, formhash);
    if (password != null) {
      await _prefs.setString(_keyPassword, password);
    }
    await _prefs.reloadCache();
  }

  Future<void> logout() async {
    _uid = null;
    _username = null;
    _formhash = null;
    _password = null;
    await _prefs.remove(_keyUid);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyFormhash);
    await _prefs.remove(_keyPassword);
    await _prefs.reloadCache();
  }

  Future<void> updateFormhash(String formhash) async {
    _formhash = formhash;
    await _prefs.setString(_keyFormhash, formhash);
    await _prefs.reloadCache();
  }
}
