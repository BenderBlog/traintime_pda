// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/core/shared/const.dart' show sheetMaxWidth;

/// Presentation only: the existing section owns all settings and side effects.
class SettingsCategoryPage extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsCategoryPage({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        physics: const ClampingScrollPhysics(),
        child: SafeArea(
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
