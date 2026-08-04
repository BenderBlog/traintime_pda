import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';
import 'package:watermeter/wearos/wear_companion_sync.dart';
import 'package:watermeter/wearos/wear_qr_page.dart';
import 'package:watermeter/wearos/wear_schedule_service.dart';
import 'package:watermeter/wearos/wear_sync_login_page.dart';

const _wearHomeDashboardPadding = EdgeInsets.fromLTRB(28, 40, 28, 28);
const double _wearHomeDashboardMaxWidth = 280;

class WearHomePage extends StatefulWidget {
  const WearHomePage({super.key});

  @override
  State<WearHomePage> createState() => _WearHomePageState();
}

class _WearHomePageState extends State<WearHomePage> {
  late Future<WearHomeData> _loadFuture;
  late final WearCompanionSyncBridge _companionBridge;
  StreamSubscription<WearCompanionSyncEnvelope>? _syncSubscription;
  Completer<void>? _pendingSync;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadCached();
    _companionBridge = WearCompanionSyncBridge();
    _syncSubscription = _companionBridge.imports.listen(
      (_) {
        if (!mounted) return;
        setState(() => _loadFuture = _loadCached());
        _pendingSync?.complete();
        _pendingSync = null;
      },
      onError: (Object error, StackTrace stackTrace) {
        _pendingSync?.completeError(error, stackTrace);
        _pendingSync = null;
      },
    );
    unawaited(_companionBridge.start());
  }

  Future<WearHomeData> _loadCached() async {
    final semester = preference.getString(
      preference.Preference.currentSemester,
    );
    return loadCachedWearHomeData(semesterCode: semester);
  }

  Future<void> _manualSync() async {
    if (_pendingSync != null) return _pendingSync!.future;
    final completer = Completer<void>();
    _pendingSync = completer;
    try {
      await _companionBridge.requestSync();
      await completer.future.timeout(const Duration(seconds: 15));
    } finally {
      if (identical(_pendingSync, completer)) _pendingSync = null;
    }
  }

  Future<void> _logout() async {
    await preference.remove(preference.Preference.idsAccount);
    await preference.remove(preference.Preference.idsPassword);
    await preference.remove(preference.Preference.currentSemester);
    await preference.remove(preference.Preference.role);
    await preference.remove(preference.Preference.isUserDefinedSemester);
    await IDSSession().clearCookieJar();
    SchoolCardSession.resetOpenId();
    await clearWearCampusCaches();
    await clearCachedWearPaymentQr();
    loginState = IDSLoginState.manual;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WearSyncLoginPage()),
    );
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    unawaited(_companionBridge.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<WearHomeData>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(
                error: snapshot.error!,
                onRetry: _manualSync,
                onLogout: _logout,
              );
            }
            return WearHomeDashboard(
              data: snapshot.requireData,
              onRefresh: _manualSync,
              onLogout: _logout,
            );
          },
        ),
      ),
    );
  }
}

class WearHomeDashboard extends StatelessWidget {
  static final _timeFormat = DateFormat('HH:mm');
  final WearHomeData data;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;

  const WearHomeDashboard({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: _wearHomeDashboardPadding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _wearHomeDashboardMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AgendaSection(
                    title: '今天',
                    items: data.todayItems,
                    timeFormat: _timeFormat,
                  ),
                  _AgendaSection(
                    title: '明天',
                    items: data.tomorrowItems,
                    timeFormat: _timeFormat,
                  ),
                  const SizedBox(height: 8),
                  const _CampusCard(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        tooltip: '刷新',
                        onPressed: () => onRefresh(),
                        icon: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        tooltip: '退出',
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusCard extends StatelessWidget {
  const _CampusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('校园卡', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WearQrPage())),
              icon: const Icon(Icons.qr_code_2),
              label: const Text('付款码'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaSection extends StatelessWidget {
  final String title;
  final List<WearAgendaItem> items;
  final DateFormat timeFormat;

  const _AgendaSection({
    required this.title,
    required this.items,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('没有安排'),
            )
          else
            for (final item in items)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _KindPill(kind: item.kind),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${timeFormat.format(item.start)}-${timeFormat.format(item.end)}',
                      ),
                      if (item.location != null)
                        Text(
                          item.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (item.subtitle != null)
                        Text(
                          item.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _KindPill extends StatelessWidget {
  final WearAgendaKind kind;

  const _KindPill({required this.kind});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (kind) {
      WearAgendaKind.course => ('课', Theme.of(context).colorScheme.primary),
      WearAgendaKind.otherExperiment => ('实', Colors.green),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final text = error.toString();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              text.substring(0, min(text.length, 120)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
            TextButton(onPressed: onLogout, child: const Text('重新登录')),
          ],
        ),
      ),
    );
  }
}
