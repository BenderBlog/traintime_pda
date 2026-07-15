// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:talker_flutter/talker_flutter.dart';


/// 设置页面
class SettingsPage extends StatelessWidget {
  final Talker talker;
  const SettingsPage({super.key, required this.talker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'ruisi.settings.title')),
      ),
      body: ListView(
        children: [
          _SectionHeader(
            title: FlutterI18n.translate(
              context,
              'ruisi.settings.section_debug',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text(
              FlutterI18n.translate(context, 'ruisi.settings.view_logs'),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TalkerScreen(talker: talker)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
