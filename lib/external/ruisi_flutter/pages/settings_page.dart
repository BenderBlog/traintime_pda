// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../controller/ruisi_controller.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  final Talker talker;
  const SettingsPage({super.key, required this.talker});

  @override
  Widget build(BuildContext context) {
    final c = RuisiController.i;

    return Watch((context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'ruisi.settings.title')),
        ),
        body: ListView(
          children: [
            // 显示设置
            _SectionHeader(
              title: FlutterI18n.translate(
                context,
                'ruisi.settings.section_display',
              ),
            ),
            SwitchListTile(
              title: Text(
                FlutterI18n.translate(context, 'ruisi.settings.full_style'),
              ),
              subtitle: Text(
                FlutterI18n.translate(
                  context,
                  'ruisi.settings.full_style_subtitle',
                ),
              ),
              value: c.settings.showFullStylePosts,
              onChanged: (value) => c.settings.setShowFullStyle(value),
            ),

            const Divider(),

            // 代理设置
            _SectionHeader(
              title: FlutterI18n.translate(
                context,
                'ruisi.settings.section_proxy',
              ),
            ),
            SwitchListTile(
              title: Text(
                FlutterI18n.translate(context, 'ruisi.settings.proxy_enable'),
              ),
              subtitle: Text(
                c.settings.proxyEnabled
                    ? '${c.settings.proxyHost}:${c.settings.proxyPort}'
                    : FlutterI18n.translate(
                        context,
                        'ruisi.settings.proxy_disabled',
                      ),
              ),
              value: c.settings.proxyEnabled,
              onChanged: (value) {
                if (value) {
                  _showProxyDialog(context, c);
                } else {
                  c.updateProxy(enabled: false, host: '', port: 0);
                }
              },
            ),
            if (c.settings.proxyEnabled)
              ListTile(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    'ruisi.settings.proxy_address',
                  ),
                ),
                subtitle: Text(
                  '${c.settings.proxyHost}:${c.settings.proxyPort}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => _showProxyDialog(context, c),
              ),

            const Divider(),

            // 调试
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
                MaterialPageRoute(
                  builder: (_) => TalkerScreen(talker: talker),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showProxyDialog(BuildContext context, RuisiController c) {
    final hostCtrl = TextEditingController(text: c.settings.proxyHost);
    final portCtrl =
        TextEditingController(text: c.settings.proxyPort.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          FlutterI18n.translate(context, 'ruisi.settings.proxy_dialog_title'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hostCtrl,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(
                  context,
                  'ruisi.settings.proxy_host',
                ),
                hintText: FlutterI18n.translate(
                  context,
                  'ruisi.settings.proxy_host_hint',
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: portCtrl,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(
                  context,
                  'ruisi.settings.proxy_port',
                ),
                hintText: FlutterI18n.translate(
                  context,
                  'ruisi.settings.proxy_port_hint',
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              FlutterI18n.translate(context, 'ruisi.common.cancel'),
            ),
          ),
          FilledButton(
            onPressed: () {
              final port = int.tryParse(portCtrl.text) ?? 0;
              c.updateProxy(
                enabled: true,
                host: hostCtrl.text,
                port: port,
              );
              Navigator.pop(ctx);
            },
            child: Text(
              FlutterI18n.translate(context, 'ruisi.common.confirm'),
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
