// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:signals/signals.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/repository/network_session.dart' show supportPath;
import 'package:watermeter/repository/preference.dart' as preference;

import '../models/forum.dart';
import '../models/topic.dart';
import '../models/message.dart';
import '../repository/ruisi_api.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

/// 睿思论坛单例控制器
///
/// 使用 signals 包实现响应式状态管理，与主程序其他 controller 模式一致。
class RuisiController {
  static final RuisiController i = RuisiController._();
  RuisiController._();

  // =========================================================================
  // 服务层
  // =========================================================================

  late final SettingsService settings;
  late final ApiService api;
  late final Talker talker;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    talker = TalkerFlutter.init();
    settings = SettingsService(preference.prefs);
    final ruisiApi = RuisiApi(cookiePath: supportPath.path, talker: talker);
    api = ApiService(ruisiApi, settings);
    _isLoggedIn.value = settings.isLogin;
  }

  // =========================================================================
  // 登录状态
  // =========================================================================

  final loginLoading = signal(false);
  final _isLoggedIn = signal(false);
  bool get isLoggedIn => _isLoggedIn.value;
  String? get username => settings.username;

  // 验证码
  final captchaRequired = signal(false);
  final captchaHash = signal<String?>(null);
  final captchaImageBytes = signal<Uint8List?>(null);
  final captchaLoading = signal(false);
  final captchaError = signal<String?>(null);
  final loginError = signal<String?>(null);

  Future<void> checkLoginCaptcha() async {
    final hash = await api.fetchLoginCaptchaHash();
    captchaHash.value = hash;
    captchaRequired.value = hash != null;

    if (captchaRequired.value) {
      await _loadCaptchaImage();
    }
  }

  Future<void> refreshCaptcha() async {
    captchaHash.value = await api.fetchLoginCaptchaHash();
    await _loadCaptchaImage();
  }

  Future<void> _loadCaptchaImage() async {
    captchaLoading.value = true;
    captchaError.value = null;

    if (captchaHash.value == null) {
      captchaLoading.value = false;
      captchaError.value = '验证码不可用';
      return;
    }

    captchaImageBytes.value = await api.fetchCaptchaImage(captchaHash.value!);
    captchaLoading.value = false;

    if (captchaImageBytes.value == null) {
      captchaError.value = '验证码加载失败';
    }
  }

  Future<bool> verifyCaptcha(String value) async {
    if (captchaHash.value == null) return false;
    return api.verifyCaptcha(captchaHash.value!, value);
  }

  Future<void> resetLoginState() async {
    await api.ruisiApi.clearCookies();
    loginError.value = null;
    await checkLoginCaptcha();
  }

  Future<bool> login(
    String username,
    String password, {
    String? seccodeVerify,
  }) async {
    loginLoading.value = true;
    loginError.value = null;

    final (ok, error) = await api.login(
      username,
      password,
      seccodeHash: captchaHash.value,
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

  // =========================================================================
  // 板块
  // =========================================================================

  final forumGroups = signal<List<ForumGroup>>([]);
  final forumLoading = signal(false);

  Future<void> loadForums() async {
    forumLoading.value = true;
    forumGroups.value = await api.getForumList();
    forumLoading.value = false;
  }

  // =========================================================================
  // 帖子列表
  // =========================================================================

  final topics = signal<List<Topic>>([]);
  final topicLoading = signal(false);
  final currentFid = signal(0);
  int _topicPage = 1;
  bool _hasMoreTopics = true;
  bool get hasMoreTopics => _hasMoreTopics;

  Future<void> loadTopics(int fid, {bool refresh = false}) async {
    if (refresh) {
      _topicPage = 1;
      _hasMoreTopics = true;
      topics.value = [];
    }

    if (!_hasMoreTopics) return;

    currentFid.value = fid;
    topicLoading.value = true;

    final newTopics = await api.getTopicList(fid, page: _topicPage);
    if (newTopics.isEmpty) {
      _hasMoreTopics = false;
    } else {
      topics.value = [...topics.value, ...newTopics];
      _topicPage++;
    }

    topicLoading.value = false;
  }

  // =========================================================================
  // 热帖 / 最新
  // =========================================================================

  final hotTopics = signal<List<Topic>>([]);
  final hotLoading = signal(false);

  Future<void> loadHotTopics() async {
    hotLoading.value = true;
    hotTopics.value = await api.getHotTopics();
    hotLoading.value = false;
  }

  final newTopics = signal<List<Topic>>([]);
  final newLoading = signal(false);
  int _newPage = 1;
  bool _hasMoreNew = true;
  bool get hasMoreNew => _hasMoreNew;

  Future<void> loadNewTopics({bool refresh = false}) async {
    if (refresh) {
      _newPage = 1;
      _hasMoreNew = true;
      newTopics.value = [];
    }

    if (!_hasMoreNew) return;

    newLoading.value = true;

    final result = await api.getNewTopics(page: _newPage);
    if (result.isEmpty) {
      _hasMoreNew = false;
    } else {
      newTopics.value = [...newTopics.value, ...result];
      _newPage++;
    }

    newLoading.value = false;
  }

  // =========================================================================
  // 最新回复
  // =========================================================================

  final newReplyTopics = signal<List<Topic>>([]);
  final newReplyLoading = signal(false);
  int _newReplyPage = 1;
  bool _hasMoreNewReply = true;
  bool get hasMoreNewReply => _hasMoreNewReply;

  Future<void> loadNewReplyTopics({bool refresh = false}) async {
    if (refresh) {
      _newReplyPage = 1;
      _hasMoreNewReply = true;
      newReplyTopics.value = [];
    }

    if (!_hasMoreNewReply) return;

    newReplyLoading.value = true;

    final result = await api.getNewReplyTopics(page: _newReplyPage);
    if (result.isEmpty) {
      _hasMoreNewReply = false;
    } else {
      newReplyTopics.value = [...newReplyTopics.value, ...result];
      _newReplyPage++;
    }

    newReplyLoading.value = false;
  }

  // =========================================================================
  // 摄影天地 (fid 561)
  // =========================================================================

  final photographyTopics = signal<List<Topic>>([]);
  final photographyLoading = signal(false);
  int _photoPage = 1;
  bool _hasMorePhoto = true;
  bool get hasMorePhoto => _hasMorePhoto;

  Future<void> loadPhotography({bool refresh = false}) async {
    if (refresh) {
      _photoPage = 1;
      _hasMorePhoto = true;
      photographyTopics.value = [];
    }

    if (!_hasMorePhoto) return;

    photographyLoading.value = true;
    final result = await api.getTopicList(561, page: _photoPage);
    if (result.isEmpty) {
      _hasMorePhoto = false;
    } else {
      photographyTopics.value = [...photographyTopics.value, ...result];
      _photoPage++;
    }
    photographyLoading.value = false;
  }

  // =========================================================================
  // 失物招领 (fid 142)
  // =========================================================================

  final lostFoundTopics = signal<List<Topic>>([]);
  final lostFoundLoading = signal(false);
  int _lostPage = 1;
  bool _hasMoreLost = true;
  bool get hasMoreLost => _hasMoreLost;

  Future<void> loadLostFound({bool refresh = false}) async {
    if (refresh) {
      _lostPage = 1;
      _hasMoreLost = true;
      lostFoundTopics.value = [];
    }

    if (!_hasMoreLost) return;

    lostFoundLoading.value = true;
    final result = await api.getTopicList(142, page: _lostPage);
    if (result.isEmpty) {
      _hasMoreLost = false;
    } else {
      lostFoundTopics.value = [...lostFoundTopics.value, ...result];
      _lostPage++;
    }
    lostFoundLoading.value = false;
  }

  // =========================================================================
  // 我的帖子
  // =========================================================================

  final myTopics = signal<List<Topic>>([]);
  final myTopicsLoading = signal(false);

  Future<void> loadMyTopics({bool refresh = false}) async {
    myTopicsLoading.value = true;
    if (refresh) myTopics.value = [];
    myTopics.value = await api.getMyTopics();
    myTopicsLoading.value = false;
  }

  // =========================================================================
  // 论坛网络收藏
  // =========================================================================

  final favorites = signal<List<Topic>>([]);
  final favoritesLoading = signal(false);

  Future<void> loadFavorites({bool refresh = false}) async {
    favoritesLoading.value = true;
    if (refresh) favorites.value = [];
    favorites.value = await api.getFavorites();
    favoritesLoading.value = false;
  }

  Future<bool> addFavorite(int tid) async {
    return api.addFavorite(tid);
  }

  // =========================================================================
  // 签到
  // =========================================================================

  final signResult = signal<SignResult?>(null);
  final signLoading = signal(false);

  Future<void> sign() async {
    signLoading.value = true;
    signResult.value = await api.sign();
    signLoading.value = false;
  }

  // =========================================================================
  // 消息通知
  // =========================================================================

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

  // =========================================================================
  // 搜索
  // =========================================================================

  final searchResults = signal<List<Topic>>([]);
  final searchLoading = signal(false);
  final searchKeyword = signal('');

  Future<void> search(String keyword) async {
    searchLoading.value = true;
    searchKeyword.value = keyword;

    searchResults.value = await api.search(keyword);
    searchLoading.value = false;
  }

  void clearSearch() {
    searchResults.value = [];
    searchKeyword.value = '';
  }

  // =========================================================================
  // 发帖
  // =========================================================================

  Future<(bool, String?)> newPost(int fid, String subject, String content) {
    return api.newPost(fid, subject, content, [], null);
  }
}
