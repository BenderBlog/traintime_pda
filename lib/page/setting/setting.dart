// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/setting_actions_controller.dart';
import 'package:watermeter/page/setting/setting_sections.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({super.key});

  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  final SettingActionsController _actions = const SettingActionsController();

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SettingHeader(),
          const SizedBox(height: 20),
          const SettingAboutSection(),
          SettingUiSection(onChanged: _refresh),
          const SettingAccountSection(),
          const SettingNotificationSection(),
          SettingClassTableSection(actions: _actions, onChanged: _refresh),
          SettingCoreSection(actions: _actions),
        ],
      ).constrained(maxWidth: 600).center().safeArea(top: true),
    );
  }
}
