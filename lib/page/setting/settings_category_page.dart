// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
