// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/login/ids_reauth_dialog.dart';
import 'package:watermeter/repository/wear_companion_sync.dart';
import 'package:watermeter/repository/xidian_ids/ids_reauth_client.dart';

class WearCompanionSyncPage extends StatefulWidget {
  const WearCompanionSyncPage({super.key});

  @override
  State<WearCompanionSyncPage> createState() => _WearCompanionSyncPageState();
}

class _WearCompanionSyncPageState extends State<WearCompanionSyncPage> {
  final _service = const WearCompanionSyncService();
  late Future<List<WearNode>> _nodesFuture = _service.connectedNodes();
  String? _sendingNodeId;
  String? _completedNodeId;
  String? _status;

  void _reload() {
    setState(() {
      _status = null;
      _nodesFuture = _service.connectedNodes();
    });
  }

  Future<void> _pair(WearNode node) async {
    if (_sendingNodeId != null) return;
    setState(() {
      _sendingNodeId = node.id;
      _completedNodeId = null;
      _status = '正在向 ${node.name} 同步…';
    });
    final previousReAuthHandler = activeIDSReAuthHandler;
    Future<Uri> pairingReAuthHandler(IDSReAuthClient client) async {
      if (!mounted) throw const IDSReAuthRequiredException();
      return showIDSReAuthDialog(context, client);
    }

    activeIDSReAuthHandler = pairingReAuthHandler;
    try {
      final paymentQrSynced = await _service.pairAndSync(node);
      if (!mounted) return;
      setState(() {
        _sendingNodeId = null;
        _completedNodeId = node.id;
        _status = paymentQrSynced
            ? '配对、数据与付款码同步完成'
            : '配对与数据同步完成，付款码未同步；请完成短信认证后重试';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sendingNodeId = null;
        _status = error.toString();
      });
    } finally {
      if (identical(activeIDSReAuthHandler, pairingReAuthHandler)) {
        activeIDSReAuthHandler = previousReAuthHandler;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同步到 XDYou Wear'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<WearNode>>(
        future: _nodesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageView(
              icon: Icons.watch_off_outlined,
              message: '无法查找手表：${snapshot.error}',
              onRetry: _reload,
            );
          }
          final nodes = snapshot.data ?? const <WearNode>[];
          if (nodes.isEmpty) {
            return _MessageView(
              icon: Icons.watch_off_outlined,
              message: '未找到已连接的 Wear OS 手表\n请先在系统中连接手表，并打开手表端的配对页面',
              onRetry: _reload,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('请先在手表端打开“配对手机”，然后选择设备：'),
              const SizedBox(height: 12),
              for (final node in nodes)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.watch_outlined),
                    title: Text(node.name),
                    subtitle: Text(node.isNearby ? '附近设备' : '已连接设备'),
                    trailing: _sendingNodeId == node.id
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : node.isPaired || _completedNodeId == node.id
                        ? OutlinedButton.icon(
                            onPressed: _sendingNodeId == null
                                ? () => _pair(node)
                                : null,
                            icon: const Icon(Icons.sync),
                            label: const Text('同步'),
                          )
                        : FilledButton(
                            onPressed: _sendingNodeId == null
                                ? () => _pair(node)
                                : null,
                            child: const Text('配对'),
                          ),
                  ),
                ),
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(_status!, textAlign: TextAlign.center),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const _MessageView({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重新查找'),
            ),
          ],
        ),
      ),
    );
  }
}
