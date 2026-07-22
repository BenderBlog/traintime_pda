// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/aircon_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AirconImeiDialog extends StatefulWidget {
  const AirconImeiDialog({super.key});

  @override
  State<AirconImeiDialog> createState() => _AirconImeiDialogState();
}

class _AirconImeiDialogState extends State<AirconImeiDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: preference.getString(preference.Preference.airconImei),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final imei = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (context) => const _AirconImeiScannerPage()),
    );
    if (imei == null || imei.isEmpty) return;
    _controller.text = imei;
  }

  Future<void> _save() async {
    try {
      await EnergyController.i.updateAirconImei(_controller.text);
      if (!mounted) return;
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "setting.aircon_imei_saved"),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "setting.aircon_imei_invalid"),
      );
    }
  }

  Future<void> _clear() async {
    await EnergyController.i.clearAirconImei();
    if (!mounted) return;
    showToast(
      context: context,
      msg: FlutterI18n.translate(context, "setting.aircon_imei_cleared"),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "setting.aircon_imei_title")),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ],
        decoration: InputDecoration(
          labelText: FlutterI18n.translate(context, "setting.aircon_imei"),
          helperText: FlutterI18n.translate(
            context,
            "setting.aircon_imei_helper",
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _scanQrCode,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(FlutterI18n.translate(context, "setting.scan_aircon_qr")),
        ),
        TextButton(
          onPressed: _clear,
          child: Text(
            FlutterI18n.translate(context, "setting.aircon_imei_clear"),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(FlutterI18n.translate(context, "cancel")),
        ),
        TextButton(
          onPressed: _save,
          child: Text(FlutterI18n.translate(context, "confirm")),
        ),
      ],
    );
  }
}

class _AirconImeiScannerPage extends StatefulWidget {
  const _AirconImeiScannerPage();

  @override
  State<_AirconImeiScannerPage> createState() => _AirconImeiScannerPageState();
}

class _AirconImeiScannerPageState extends State<_AirconImeiScannerPage> {
  final QRCodeDartScanController _controller = QRCodeDartScanController();
  bool _flashOn = false;
  bool _finished = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "setting.scan_aircon_qr")),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await _controller.toggleFlash();
              if (!mounted) return;
              setState(() {
                _flashOn = _controller.isFlashOn;
              });
            },
          ),
        ],
      ),
      body: QRCodeDartScanView(
        controller: _controller,
        onCapture: (result) {
          if (_finished) return;
          final imei = AirconSession.tryParseImei(result.text);
          if (imei == null) {
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                "setting.aircon_imei_invalid",
              ),
            );
            return;
          }

          _finished = true;
          Navigator.of(context).pop(imei);
        },
      ),
    );
  }
}
