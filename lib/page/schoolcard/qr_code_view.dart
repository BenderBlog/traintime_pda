// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';

class QRCodeView extends StatefulWidget {
  const QRCodeView({super.key});

  @override
  State<QRCodeView> createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeView> {
  Future<Uint8List> qrCode = SchoolCardSession().getQRCode();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "school_card_window.qr_code")),
      content: FutureBuilder<Uint8List>(
        future: qrCode,
        builder: (context, snapshot) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white.withValues(alpha: 0.85),
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : snapshot.hasError
                    ? SizedBox(
                        width: 200,
                        child: Text(
                          FlutterI18n.translate(
                            context,
                            "school_card_window.qr_code",
                            translationParams: {
                              "info": snapshot.error.toString(),
                            },
                          ),
                        ),
                      )
                    : Image.memory(snapshot.data!, width: 200, height: 200),
              ),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              qrCode = SchoolCardSession().getQRCode();
            });
          },
          child: Text(
            FlutterI18n.translate(context, "school_card_window.reload"),
          ),
        ),
      ],
    );
  }
}
