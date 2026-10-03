// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Presentation only: the existing section owns all settings and side effects.
class SettingsCategoryPage extends StatelessWidget {
  final String titleKey;
  final Widget child;

  const SettingsCategoryPage({
    super.key,
    required this.titleKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FlutterI18n.translate(context, titleKey))),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [child],
            ),
          ),
        ),
      ),
    );
  }
}
