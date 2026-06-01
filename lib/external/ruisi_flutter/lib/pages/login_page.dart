// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../controller/ruisi_controller.dart';

/// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _captchaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 验证码状态（从控制器下沉）
  bool _captchaRequired = false;
  String? _captchaHash;
  Uint8List? _captchaImageBytes;
  bool _captchaLoading = false;
  String? _captchaError;

  RuisiService get _c => GetIt.instance<RuisiService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginCaptcha();
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkLoginCaptcha() async {
    final hash = await _c.api.fetchLoginCaptchaHash();
    if (!mounted) return;
    setState(() {
      _captchaHash = hash;
      _captchaRequired = hash != null;
    });

    if (_captchaRequired) {
      await _loadCaptchaImage();
    }
  }

  Future<void> _refreshCaptcha() async {
    final hash = await _c.api.fetchLoginCaptchaHash();
    if (!mounted) return;
    setState(() {
      _captchaHash = hash;
    });
    await _loadCaptchaImage();
  }

  Future<void> _loadCaptchaImage() async {
    setState(() {
      _captchaLoading = true;
      _captchaError = null;
    });

    if (_captchaHash == null) {
      if (!mounted) return;
      setState(() {
        _captchaLoading = false;
        _captchaError = '验证码不可用';
      });
      return;
    }

    final bytes = await _c.api.fetchCaptchaImage(_captchaHash!);
    if (!mounted) return;
    setState(() {
      _captchaImageBytes = bytes;
      _captchaLoading = false;
      if (_captchaImageBytes == null) {
        _captchaError = '验证码加载失败';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'ruisi.login.title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/ruisi_flutter/app_logo.png',
                    width: 80,
                    height: 80,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.forum, size: 80, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 用户名
              TextFormField(
                controller: _usernameCtrl,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    'ruisi.login.username',
                  ),
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? FlutterI18n.translate(
                        context,
                        'ruisi.login.username_hint',
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // 密码
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    'ruisi.login.password',
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? FlutterI18n.translate(
                        context,
                        'ruisi.login.password_hint',
                      )
                    : null,
              ),

              // 验证码
              if (_captchaRequired)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _captchaCtrl,
                          decoration: InputDecoration(
                            labelText: FlutterI18n.translate(
                              context,
                              'ruisi.login.captcha',
                            ),
                            prefixIcon: const Icon(Icons.security),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              _captchaRequired && (v == null || v.isEmpty)
                              ? FlutterI18n.translate(
                                  context,
                                  'ruisi.login.captcha_hint',
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _refreshCaptcha,
                        child: Container(
                          width: 120,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _captchaLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _captchaImageBytes != null
                              ? Image.memory(
                                  _captchaImageBytes!,
                                  fit: BoxFit.contain,
                                )
                              : _captchaError != null
                              ? Text(
                                  _captchaError!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.refresh,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    size: 24,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 错误信息
              ValueListenableBuilder<String?>(
                valueListenable: _c.loginError,
                builder: (context, error, _) {
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 登录按钮
              ValueListenableBuilder<bool>(
                valueListenable: _c.loginLoading,
                builder: (context, loading, _) {
                  return FilledButton(
                    onPressed: loading ? null : _handleLogin,
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            FlutterI18n.translate(
                              context,
                              'ruisi.common.login',
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 重置登录状态按钮
              OutlinedButton.icon(
                onPressed: () => _handleResetLoginState(context),
                icon: const Icon(Icons.refresh),
                label: Text(
                  FlutterI18n.translate(
                    context,
                    'ruisi.login.reset_login_state',
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 查看日志按钮
              OutlinedButton.icon(
                onPressed: () => _handleViewLogs(context),
                icon: const Icon(Icons.bug_report),
                label: Text(
                  FlutterI18n.translate(context, 'ruisi.login.view_logs'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 事件处理
  // =========================================================================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    String? seccodeVerify;
    if (_captchaRequired) {
      seccodeVerify = _captchaCtrl.text;
    }

    final ok = await _c.login(
      _usernameCtrl.text,
      _passwordCtrl.text,
      seccodeHash: _captchaHash,
      seccodeVerify: seccodeVerify,
    );

    if (!mounted) return;

    if (!ok && _captchaRequired) {
      _captchaCtrl.clear();
    }
  }

  Future<void> _handleResetLoginState(BuildContext context) async {
    await _c.logout();
    if (context.mounted) {
      _checkLoginCaptcha();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FlutterI18n.translate(context, 'ruisi.login.reset_success'),
          ),
        ),
      );
    }
  }

  void _handleViewLogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TalkerScreen(talker: _c.talker)),
    );
  }
}
