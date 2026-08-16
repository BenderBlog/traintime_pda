import 'package:watermeter/generated/translations.g.dart';
// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/urls.dart';

/// 关于页面
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _openUrl(String url) {
    if (url.isNotEmpty) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.ruisi.about.title),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 40),
          // Logo
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/ruisi_flutter/app_logo.png',
                width: 80,
                height: 80,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.forum, size: 80, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              context.t.ruisi.about.appName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              context.t.ruisi.about.subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),

          // 版本
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(context.t.ruisi.about.version),
            subtitle: Text(
              context.t.ruisi.about.versionNumber,
            ),
          ),

          // 源代码
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(
              context.t.ruisi.about.sourceCode,
            ),
            subtitle: Text(Urls.homePage),
            onTap: () => _openUrl(Urls.homePage),
          ),

          // 反馈
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text(
              context.t.ruisi.about.bugReport,
            ),
            subtitle: Text(
              context.t.ruisi.about.bugReportSubtitle,
            ),
            onTap: () => _openUrl('${Urls.homePage}/issues'),
          ),

          const Divider(),

          // 隐私政策
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(
              context.t.ruisi.about.privacyPolicy,
            ),
            onTap: () => _showPrivacyPolicy(context),
          ),

          const Divider(),

          // 开源许可
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.t.ruisi.about.license,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.t.ruisi.about.privacyPolicy,
        ),
        content: SingleChildScrollView(
          child: Text(
            context.t.ruisi.about.privacyPolicyContent,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t.ruisi.common.confirm),
          ),
        ],
      ),
    );
  }
}
