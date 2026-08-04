import 'dart:async';

import 'package:flutter/material.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/wearos/wear_companion_sync.dart';
import 'package:watermeter/wearos/wear_home_page.dart';

class WearSyncLoginPage extends StatefulWidget {
  const WearSyncLoginPage({super.key});

  @override
  State<WearSyncLoginPage> createState() => _WearSyncLoginPageState();
}

class _WearSyncLoginPageState extends State<WearSyncLoginPage> {
  late final WearCompanionSyncBridge _bridge;
  StreamSubscription<WearCompanionSyncEnvelope>? _subscription;
  String _status = '请在手机端打开“设置 > XDYou Wear”，选择这块手表';
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    _bridge = WearCompanionSyncBridge();
    _subscription = _bridge.imports.listen(
      (_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WearHomePage()),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        log.warning(
          '[WearSyncLoginPage] Direct pairing failed',
          error,
          stackTrace,
        );
        if (mounted) setState(() => _status = '同步失败：$error');
      },
    );
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      await _bridge.start();
      await _bridge.beginDirectPairing();
      if (mounted) setState(() => _starting = false);
    } catch (error, stackTrace) {
      log.warning(
        '[WearSyncLoginPage] Cannot start pairing',
        error,
        stackTrace,
      );
      if (mounted) {
        setState(() {
          _starting = false;
          _status = '无法开始配对：$error';
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    unawaited(_bridge.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_starting ? Icons.sync : Icons.watch_outlined, size: 54),
                  const SizedBox(height: 12),
                  Text(
                    '等待手机配对',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(_status, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  if (_starting) const CircularProgressIndicator(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('返回'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
