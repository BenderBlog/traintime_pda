// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Image captcha widget for IDS recheck (二次验证).
// Follows the same pattern as CaptchaWidget: StatefulWidget + Navigator.pop.
//
// The widget receives a captcha image and a fetch callback.
// It pops the user-entered captcha code on submit, or null on cancel.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Callback to fetch a new captcha image.
/// Returns the image bytes.
typedef CaptchaFetchCallback = Future<Uint8List> Function();

class ImageCaptchaWidget extends StatefulWidget {
  final Uint8List initialImage;
  final CaptchaFetchCallback onRefresh;

  const ImageCaptchaWidget({
    super.key,
    required this.initialImage,
    required this.onRefresh,
  });

  @override
  State<ImageCaptchaWidget> createState() => _ImageCaptchaWidgetState();
}

class _ImageCaptchaWidgetState extends State<ImageCaptchaWidget> {
  final _controller = TextEditingController();
  Uint8List? _imageData;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _imageData = widget.initialImage;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final image = await widget.onRefresh();
      if (mounted) {
        setState(() {
          _imageData = image;
          _controller.clear();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.isNotEmpty) {
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "login.image_captcha.title")),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _loading ? null : _refresh,
              child: _imageData != null
                  ? Image.memory(
                      _imageData!,
                      width: 200,
                      fit: BoxFit.fitWidth,
                    )
                  : const SizedBox(
                      width: 200,
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              FlutterI18n.translate(context, "login.image_captcha.refresh_hint"),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: FlutterI18n.translate(context, "login.image_captcha.hint"),
                  counterText: "",
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: Text(FlutterI18n.translate(context, "login.image_captcha.confirm")),
            ),
          ],
        ),
      ),
    );
  }
}
