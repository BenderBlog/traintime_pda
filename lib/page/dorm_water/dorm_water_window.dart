// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:convert' show base64Decode;
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/dorm_water_session.dart';

class DormWaterWindow extends StatefulWidget {
  const DormWaterWindow({super.key});

  @override
  State<DormWaterWindow> createState() => _DormWaterWindowState();
}

class _DormWaterWindowState extends State<DormWaterWindow> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageCodeController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  
  late DormWaterSession _session;
  String? _captchaImageBase64;
  bool _isCaptchaLoading = false;
  String? _captchaError;

  @override
  void initState() {
    super.initState();
    _session = DormWaterSession();
    _loadCaptcha();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _imageCodeController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  /// Load captcha image from API
  Future<void> _loadCaptcha() async {
    setState(() {
      _isCaptchaLoading = true;
      _captchaError = null;
    });

    try {
      final captchaData = await _session.getCaptcha();
      setState(() {
        _captchaImageBase64 = captchaData.imageBase64;
        _isCaptchaLoading = false;
      });
    } catch (e) {
      setState(() {
        _captchaError = e.toString();
        _isCaptchaLoading = false;
      });
    }
  }

  /// Refresh captcha by calling _loadCaptcha again
  void _refreshCaptcha() {
    _loadCaptcha();
    _imageCodeController.clear();
  }

  /// Send SMS code to user's phone
  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();
    final imageCode = _imageCodeController.text.trim();

    if (phone.isEmpty) {
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.phone_required"));
      return;
    }

    if (imageCode.isEmpty) {
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.image_code_required"));
      return;
    }

    try {
      await _session.sendSmsCode(
        phoneNumber: phone,
        imageCode: imageCode,
      );
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.sms_sent"));
    } catch (e) {
      if (!mounted) return;
      showToast(context: context, msg: "${FlutterI18n.translate(context, "dorm_water.sms_failed")}: $e");
      _loadCaptcha();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "dorm_water.title")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Phone input
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "dorm_water.phone"),
            ),
          ),
          const SizedBox(height: 12),
          // Image code input with captcha image on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _imageCodeController,
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(context, "dorm_water.image_code"),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildCaptchaImage(context),
            ],
          ),
          const SizedBox(height: 12),
          // SMS code input
          TextField(
            controller: _smsCodeController,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "dorm_water.sms_code"),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _sendSmsCode,
                  child: Text(
                    FlutterI18n.translate(context, "dorm_water.send_sms"),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: Text(
                    FlutterI18n.translate(context, "dorm_water.login"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build captcha image widget (clickable to refresh)
  Widget _buildCaptchaImage(BuildContext context) {
    // Loading state
    if (_isCaptchaLoading) {
      return Container(
        width: 140,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Error state
    if (_captchaError != null) {
      return GestureDetector(
        onTap: _refreshCaptcha,
        child: Container(
          width: 140,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              FlutterI18n.translate(context, "dorm_water.captcha_error"),
              style: const TextStyle(color: Colors.red, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Image loaded state
    if (_captchaImageBase64 != null) {
      return GestureDetector(
        onTap: _refreshCaptcha,
        child: Container(
          width: 140,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.memory(
            base64Decode(_captchaImageBase64!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Placeholder
    return Container(
      width: 140,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text("No image", style: TextStyle(fontSize: 10)),
      ),
    );
  }
}
