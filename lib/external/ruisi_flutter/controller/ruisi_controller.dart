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

  final forumGroups = signal<List<ForumGroup>>([]);
  final forumLoading = signal(false);
  Future<void> loadForums() async {
    forumLoading.value = true;
    forumGroups.value = await api.getForumList();
    forumLoading.value = false;
  }

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
