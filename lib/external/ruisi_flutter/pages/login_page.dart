// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RuisiController.i.checkLoginCaptcha();
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = RuisiController.i;

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
              Watch((context) {
                if (!c.captchaRequired.value) return const SizedBox.shrink();
                final isLoading = c.captchaLoading.value;
                final imageBytes = c.captchaImageBytes.value;
                final error = c.captchaError.value;
                return Padding(
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
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => c.refreshCaptcha(),
                            ),
                          ),
                          validator: (v) {
                            if (c.captchaRequired.value &&
                                (v == null || v.isEmpty)) {
                              return FlutterI18n.translate(
                                context,
                                'ruisi.login.captcha_hint',
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => c.refreshCaptcha(),
                        child: Container(
                          width: 120,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: isLoading
                              ? const SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : imageBytes != null
                              ? Image.memory(
                                  imageBytes,
                                  height: 48,
                                  fit: BoxFit.contain,
                                )
                              : error != null
                              ? Text(
                                  error,
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
                );
              }),

              // 错误信息
              Watch((context) {
                final error = c.loginError.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // 登录按钮
              Watch((context) {
                return FilledButton(
                  onPressed: c.loginLoading.value ? null : _handleLogin,
                  child: c.loginLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          FlutterI18n.translate(context, 'ruisi.common.login'),
                        ),
                );
              }),
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final c = RuisiController.i;
    String? seccodeVerify;
    if (c.captchaRequired.value) {
      seccodeVerify = _captchaCtrl.text;
    }

    final ok = await c.login(
      _usernameCtrl.text,
      _passwordCtrl.text,
      seccodeVerify: seccodeVerify,
    );

    if (!mounted) return;

    if (!ok) {
      if (c.captchaRequired.value) {
        _captchaCtrl.clear();
      }
    }
  }

  Future<void> _handleResetLoginState(BuildContext context) async {
    await RuisiController.i.logout();
    if (context.mounted) {
      RuisiController.i.checkLoginCaptcha();
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
      MaterialPageRoute(
        builder: (_) => TalkerScreen(talker: RuisiController.i.talker),
      ),
    );
  }
}
