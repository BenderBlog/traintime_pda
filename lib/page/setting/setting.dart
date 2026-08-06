// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/page/setting/groups/about_section.dart';
import 'package:watermeter/page/setting/groups/account_section.dart';
import 'package:watermeter/page/setting/groups/classtable_section.dart';
import 'package:watermeter/page/setting/groups/core_section.dart';
import 'package:watermeter/page/setting/groups/notification_section.dart';
import 'package:watermeter/page/setting/groups/ui_section.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({super.key});
  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const AboutSection(),
          const UiSection(),
          const AccountSection(),
          if (Platform.isAndroid || Platform.isIOS) const NotificationSection(),
          const ClasstableSection(),
          const CoreSection(),
        ],
      ),
    );
  }
}
