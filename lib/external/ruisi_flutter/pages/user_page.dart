// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/external/ruisi_flutter/pages/my_posts_page.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../constants/urls.dart';
import '../controller/ruisi_controller.dart';
import '../models/message.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'about_page.dart';

/// 用户页面（我的帖子、我的资料）
class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    RuisiService c = GetIt.instance<RuisiService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'ruisi.user.title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(12),
                    child: Image.network(
                      Urls.getAvaterUrl(c.settings.uid, size: 0),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, size: 24),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.username ??
                        FlutterI18n.translate(context, 'ruisi.user.unknown'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'uid: ${c.settings.uid ?? ""}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.book),
            title: Text(FlutterI18n.translate(context, 'ruisi.home.my_posts')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(const MyPostsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(
              FlutterI18n.translate(context, 'ruisi.home.my_favorites'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(const FavoritesPage()),
          ),
          _CheckInListTile(onCheckIn: c.api.sign),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(FlutterI18n.translate(context, 'ruisi.home.settings')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SettingsPage(talker: c.talker)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(FlutterI18n.translate(context, 'ruisi.home.about')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(const AboutPage()),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              FlutterI18n.translate(context, 'ruisi.common.logout'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              await c.logout();
              if (!context.mounted) return;
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    FlutterI18n.translate(context, 'ruisi.common.logged_out'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CheckInListTile extends StatefulWidget {
  final Future<SignResult> Function() onCheckIn;
  const _CheckInListTile({required this.onCheckIn});

  @override
  State<_CheckInListTile> createState() => __CheckInListTileState();
}

class __CheckInListTileState extends State<_CheckInListTile> {
  SignResult? signResult;
  bool signLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle_outline),
      title: Text(FlutterI18n.translate(context, 'ruisi.home.daily_checkin')),
      trailing: signLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: signLoading
          ? null
          : () async {
              setState(() {
                signLoading = true;
              });
              signResult = await widget.onCheckIn();
              if (!context.mounted) return;
              setState(() {
                signLoading = false;
              });
              final msg = signResult?.message ?? '签到完成';
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
            },
    );
  }
}
