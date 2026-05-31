// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../models/forum.dart';
import '../models/topic.dart';
import '../models/message.dart';
import '../repository/ruisi_api.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

/// 会话刷新结果
enum SessionRefreshResult {
  /// 刷新成功
  success,

  /// 需要验证码
  needCaptcha,

  /// 刷新失败（密码错误等），应回到登录页
  failed,
}

class RuisiService {
  late final SettingsService settings;
  late final ApiService api;
  final Talker talker;

  RuisiService({
    required SharedPreferencesWithCache prefs,
    required String cookiePath,
    required this.talker,
  }) {
    settings = SettingsService(prefs);
    final ruisiApi = RuisiApi(cookiePath: cookiePath, talker: talker);
    api = ApiService(ruisiApi, settings);
    _isLoggedIn.value = settings.isLogin;
  }

  final loginLoading = ValueNotifier<bool>(false);
  final loginError = ValueNotifier<String?>(null);
  final _isLoggedIn = ValueNotifier<bool>(false);
  bool get isLoggedIn => _isLoggedIn.value;
  ValueNotifier<bool> get isLoggedInNotifier => _isLoggedIn;
  String? get username => settings.username;

  Future<bool> login(
    String username,
    String password, {
    String? seccodeHash,
    String? seccodeVerify,
  }) async {
    loginLoading.value = true;
    loginError.value = null;

    final (ok, error) = await api.login(
      username,
      password,
      seccodeHash: seccodeHash,
      seccodeVerify: seccodeVerify,
    );

    loginLoading.value = false;
    loginError.value = error;
    if (ok) _isLoggedIn.value = true;
    return ok;
  }

  Future<void> logout() async {
    try {
      if (settings.formhash != null) {
        await api.ruisiApi.get(
          'member.php?mod=logging&action=logout&formhash=${settings.formhash}',
        );
      }
    } catch (_) {}

    await api.ruisiApi.clearCookies();
    await settings.logout();
    _isLoggedIn.value = false;
  }

  Future<SessionRefreshResult> refreshSession() async {
    final password = settings.password;
    final uname = settings.username;
    if (uname == null || password == null) {
      talker.warning('无法刷新会话: 未保存用户名或密码');
      return SessionRefreshResult.failed;
    }

    talker.info('尝试静默刷新会话...');
    final (ok, error) = await api.login(uname, password);

    if (ok) {
      _isLoggedIn.value = true;
      talker.info('会话刷新成功');
      return SessionRefreshResult.success;
    }

    // 判断是否因为需要验证码而失败
    // api.fetchLoginCaptchaHash() 返回非 null 表示服务端要求验证码
    final captchaHash = await api.fetchLoginCaptchaHash();
    if (captchaHash != null) {
      talker.info('服务端要求验证码');
      return SessionRefreshResult.needCaptcha;
    }

    // 其他失败（密码错误等）
    talker.warning('会话刷新失败: $error');
    return SessionRefreshResult.failed;
  }

  final forumGroups = signal<List<ForumGroup>>([]);
  final forumLoading = signal(false);
  Future<void> loadForums() async {
    forumLoading.value = true;
    forumGroups.value = await api.getForumList();
    forumLoading.value = false;
  }

  /*
  final replyNotifications = signal<List<ReplyNotification>>([]);
  final atNotifications = signal<List<AtNotification>>([]);
  final messageLoading = signal(false);

  Future<void> loadMessages() async {
    messageLoading.value = true;

    final results = await Future.wait([
      api.getReplyNotifications(),
      api.getAtNotifications(),
    ]);

    replyNotifications.value = results[0] as List<ReplyNotification>;
    atNotifications.value = results[1] as List<AtNotification>;

    messageLoading.value = false;
  }
  */

  String? _searchId;
  Future<List<Topic>> search(String keyword, int page) async {
    if (_searchId == null || page == 1) {
      final result = await api.search(keyword);
      if (result.hasError) {
        throw result.error!;
      }
      _searchId = result.searchId;
      return result.topics;
    }

    final result = await api.searchPage(_searchId!, keyword, page);
    if (result.hasError) {
      _searchId = null;
      throw result.error!;
    }
    return result.topics;
  }
}
