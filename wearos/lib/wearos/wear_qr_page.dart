import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/repository/network_session.dart' as network;
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';
import 'package:watermeter/wearos/wear_ids_reauth.dart';

typedef _PaymentQrResult = ({
  Uint8List bytes,
  bool fromCache,
  DateTime fetchedAt,
});

File get _paymentQrCache =>
    File('${network.supportPath.path}/WearPaymentQr.png');

Future<void> clearCachedWearPaymentQr() async {
  if (await _paymentQrCache.exists()) await _paymentQrCache.delete();
}

Future<void> storeCachedWearPaymentQr(
  Uint8List bytes, {
  required DateTime fetchedAt,
}) async {
  await _paymentQrCache.writeAsBytes(bytes, flush: true);
  await _paymentQrCache.setLastModified(fetchedAt);
}

class WearQrPage extends StatefulWidget {
  const WearQrPage({super.key});

  @override
  State<WearQrPage> createState() => _WearQrPageState();
}

class _WearQrPageState extends State<WearQrPage> {
  static const _nativeChannel = MethodChannel(
    'io.github.benderblog.traintime_pda/wear_companion_sync',
  );
  static const _paymentChannel = MethodChannel(
    'io.github.benderblog.traintime_pda/wear_payment',
  );
  late Future<_PaymentQrResult> _qrFuture;
  bool _usingWatchAuthentication = false;

  @override
  void initState() {
    super.initState();
    unawaited(_setKeepScreenOn(true));
    _qrFuture = _loadQrWithCache();
  }

  Future<void> _setKeepScreenOn(bool enabled) async {
    try {
      await _nativeChannel.invokeMethod<void>('setKeepScreenOn', enabled);
    } on PlatformException {
      // The QR flow still works when the host cannot expose this optimization.
    }
  }

  @override
  void dispose() {
    unawaited(_setKeepScreenOn(false));
    super.dispose();
  }

  void _retry() {
    setState(() {
      _usingWatchAuthentication = false;
      _qrFuture = _loadQrWithCache(forceRefresh: true);
    });
  }

  void _authenticateOnWatch() {
    _paymentChannel.setMethodCallHandler(null);
    setState(() {
      _usingWatchAuthentication = true;
      _qrFuture = _loadQrDirectlyWithCache();
    });
  }

  Future<_PaymentQrResult> _loadQrDirectlyWithCache() async {
    try {
      return await _requestQrDirectly();
    } catch (_) {
      if (!await _paymentQrCache.exists()) rethrow;
      return (
        bytes: await _paymentQrCache.readAsBytes(),
        fromCache: true,
        fetchedAt: await _paymentQrCache.lastModified(),
      );
    }
  }

  Future<_PaymentQrResult> _loadQrWithCache({bool forceRefresh = false}) async {
    if (!forceRefresh && await _paymentQrCache.exists()) {
      return (
        bytes: await _paymentQrCache.readAsBytes(),
        fromCache: true,
        fetchedAt: await _paymentQrCache.lastModified(),
      );
    }
    try {
      return await _requestQrFromPhone();
    } catch (_) {
      try {
        return await _requestQrDirectly();
      } catch (_) {
        if (!await _paymentQrCache.exists()) rethrow;
        return (
          bytes: await _paymentQrCache.readAsBytes(),
          fromCache: true,
          fetchedAt: await _paymentQrCache.lastModified(),
        );
      }
    }
  }

  Future<_PaymentQrResult> _requestQrFromPhone() async {
    try {
      final completer = Completer<String>();
      _paymentChannel.setMethodCallHandler((call) async {
        if (call.method == 'receivePaymentQrResponse' &&
            call.arguments is String &&
            !completer.isCompleted) {
          completer.complete(call.arguments as String);
        }
      });
      await _paymentChannel.invokeMethod<void>('requestPaymentQr');
      final raw = await completer.future.timeout(const Duration(minutes: 3));
      final json = jsonDecode(raw);
      if (json is! Map || json['ok'] != true) {
        throw StateError('Companion phone could not provide a payment QR.');
      }
      final encoded = json['pngBase64'];
      final fetchedAtEpochMs = json['fetchedAtEpochMs'];
      if (encoded is! String || fetchedAtEpochMs is! int) {
        throw const FormatException('Invalid companion payment QR response.');
      }
      final bytes = base64Decode(encoded);
      final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtEpochMs);
      await storeCachedWearPaymentQr(bytes, fetchedAt: fetchedAt);
      return (bytes: bytes, fromCache: false, fetchedAt: fetchedAt);
    } finally {
      _paymentChannel.setMethodCallHandler(null);
    }
  }

  Future<_PaymentQrResult> _requestQrDirectly() async {
    final session = SchoolCardSession();
    await session.authenticateWithStoredCredentials(
      reAuthHandler: (client) {
        if (!mounted) throw const WearIDSReAuthCancelledException();
        return showWearIDSReAuthPage(context, client);
      },
    );
    final bytes = await session.getQRCode();
    final fetchedAt = DateTime.now();
    await storeCachedWearPaymentQr(bytes, fetchedAt: fetchedAt);
    return (bytes: bytes, fromCache: false, fetchedAt: fetchedAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<_PaymentQrResult>(
          future: _qrFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(34, 28, 34, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _usingWatchAuthentication ? '正在由手表认证' : '正在向手机请求付款码',
                        textAlign: TextAlign.center,
                      ),
                      if (!_usingWatchAuthentication) ...[
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _authenticateOnWatch,
                          child: const Text('改用手表认证'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_2),
                      const SizedBox(height: 6),
                      const Text('付款码获取失败', textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: _retry,
                            child: const Text('重试'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('返回'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            final result = snapshot.requireData;
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(22, 28, 22, 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.memory(
                            result.bytes,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.fromCache)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(34, 2, 34, 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text(
                          '缓存 ${DateFormat('MM-dd HH:mm').format(result.fetchedAt)}，可能失效',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
