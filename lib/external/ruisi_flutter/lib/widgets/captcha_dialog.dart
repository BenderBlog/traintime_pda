// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';

import '../controller/ruisi_controller.dart';

class CaptchaDialog extends StatefulWidget {
  const CaptchaDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CaptchaDialog(),
    );
    return result ?? false;
  }

  @override
  State<CaptchaDialog> createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends State<CaptchaDialog> {
  final _captchaCtrl = TextEditingController();

  String? _captchaHash;
  Uint8List? _captchaImageBytes;
  bool _loading = false;
  String? _captchaError;
  bool _submitting = false;
  String? _submitError;

  RuisiService get _c => GetIt.instance<RuisiService>();

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  @override
  void dispose() {
    _captchaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha() async {
    setState(() {
      _loading = true;
      _captchaError = null;
    });

    final hash = await _c.api.fetchLoginCaptchaHash();
    if (!mounted) return;

    _captchaHash = hash;
    if (hash == null) {
      setState(() {
        _loading = false;
        _captchaError = '验证码不可用';
      });
      return;
    }

    final bytes = await _c.api.fetchCaptchaImage(hash);
    if (!mounted) return;

    setState(() {
      _captchaImageBytes = bytes;
      _loading = false;
      if (bytes == null) _captchaError = '验证码加载失败';
    });
  }

  Future<void> _handleSubmit() async {
    final text = _captchaCtrl.text.trim();
    if (text.isEmpty || _captchaHash == null) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    final ok = await _c.login(
      _c.settings.username!,
      _c.settings.password!,
      seccodeHash: _captchaHash,
      seccodeVerify: text,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _submitting = false;
        _submitError = _c.loginError.value ?? '登录失败';
      });
      _captchaCtrl.clear();
      _loadCaptcha();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, 'ruisi.login.captcha')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 验证码图片
          GestureDetector(
            onTap: _loading ? null : _loadCaptcha,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _loading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _captchaImageBytes != null
                  ? Image.memory(_captchaImageBytes!, fit: BoxFit.contain)
                  : _captchaError != null
                  ? Center(
                      child: Text(
                        _captchaError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _captchaCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(
                context,
                'ruisi.login.captcha_hint',
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),

          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _submitError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(FlutterI18n.translate(context, 'ruisi.common.cancel')),
        ),
        FilledButton(
          onPressed: _submitting ? null : _handleSubmit,
          child: _submitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(FlutterI18n.translate(context, 'ruisi.common.confirm')),
        ),
      ],
    );
  }
}
