// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../controller/ruisi_controller.dart';
import 'home_page.dart';
import 'login_page.dart';
import '../widgets/captcha_dialog.dart';

class RuisiApp extends StatefulWidget {
  final SharedPreferencesWithCache prefs;
  final String cookiePath;
  final Talker talker;
  const RuisiApp({
    super.key,
    required this.prefs,
    required this.cookiePath,
    required this.talker,
  });

  @override
  State<RuisiApp> createState() => _RuisiAppState();
}

class _RuisiAppState extends State<RuisiApp>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 会话检查状态：null=未登录, true=有效, false=失效
  bool? _sessionValid;
  bool _checking = false;

  RuisiService get _c => GetIt.instance<RuisiService>();

  @override
  void initState() {
    super.initState();
    GetIt.instance.registerSingleton<RuisiService>(
      RuisiService(
        prefs: widget.prefs,
        cookiePath: widget.cookiePath,
        talker: widget.talker,
      ),
    );

    // 监听登录状态变化，驱动页面切换
    _c.isLoggedInNotifier.addListener(_onLoginChanged);

    if (_c.isLoggedIn) {
      _checking = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
    }
  }

  @override
  void dispose() {
    _c.isLoggedInNotifier.removeListener(_onLoginChanged);
    super.dispose();
  }

  void _onLoginChanged() {
    if (!mounted) return;
    setState(() {
      if (_c.isLoggedIn) {
        _checking = true;
        _sessionValid = null;
      } else {
        _checking = false;
        _sessionValid = null;
      }
    });

    if (_c.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
    }
  }

  /// 会话有效性检测 + 三层续登。
  Future<void> _checkSession() async {
    final valid = await _c.api.validateSession();
    if (!mounted) return;

    if (valid) {
      setState(() {
        _sessionValid = true;
        _checking = false;
      });
      return;
    }

    // 会话失效，尝试刷新
    final result = await _c.refreshSession();
    if (!mounted) return;

    switch (result) {
      case SessionRefreshResult.success:
        setState(() {
          _sessionValid = true;
          _checking = false;
        });
      case SessionRefreshResult.needCaptcha:
        // 弹出验证码弹窗
        final dialogOk = await CaptchaDialog.show(context);
        if (!mounted) return;
        setState(() {
          _sessionValid = dialogOk;
          _checking = false;
        });
      case SessionRefreshResult.failed:
        setState(() {
          _sessionValid = false;
          _checking = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_c.isLoggedIn) return const LoginPage();
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _sessionValid == true ? const HomePage() : const LoginPage();
  }
}
