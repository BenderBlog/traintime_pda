// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
/*
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;

bool get _canUseCameraScanner => Platform.isAndroid || Platform.isIOS;

DecodeParams _airconQrImageDecodeParams({bool isMultiScan = false}) =>
    DecodeParams(
      imageFormat: ImageFormat.rgb,
      format: Format.matrixCodes,
      tryHarder: true,
      tryInverted: true,
      tryDownscale: true,
      maxSize: 1600,
      isMultiScan: isMultiScan,
    );

String? _tryParseAirconImei(Codes results) {
  for (final result in results.codes) {
    final imei = AirconController.tryParseImei(result.text ?? "");
    if (imei != null) return imei;
  }
  return null;
}

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
    if (!_canUseCameraScanner) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          "setting.aircon_camera_unavailable",
        ),
      );
      return;
    }

    final imei = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (context) => const _AirconImeiScannerPage()),
    );
    if (imei == null || imei.isEmpty) return;
    _controller.text = imei;
  }

  Future<void> _pickQrCodeImage() async {
    try {
      final file = await pickFile(type: FileType.image);
      final path = file?.path;
      if (path == null || path.isEmpty) return;

      final result = await zx.readBarcodeImagePathString(
        path,
        _airconQrImageDecodeParams(),
      );
      if (!mounted) return;

      var imei = AirconController.tryParseImei(result.text ?? "");
      if (imei == null) {
        final results = await zx.readBarcodesImagePathString(
          path,
          _airconQrImageDecodeParams(isMultiScan: true),
        );
        if (!mounted) return;
        imei = _tryParseAirconImei(results);
      }

      if (imei == null) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(context, "setting.aircon_imei_invalid"),
        );
        return;
      }

      _controller.text = imei;
    } catch (e) {
      if (!mounted) return;
      showToast(
        context: context,
        msg: FlutterI18n.translate(context, "setting.aircon_imei_invalid"),
      );
    }
  }

  Future<void> _save() async {
    try {
      await AirconController.i.updateImei(_controller.text);
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
    await AirconController.i.clearImei();
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "setting.aircon_imei"),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (_canUseCameraScanner)
                  TextButton.icon(
                    onPressed: _scanQrCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(
                      FlutterI18n.translate(context, "setting.scan_aircon_qr"),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _pickQrCodeImage,
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.pick_aircon_qr_image",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
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
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "setting.scan_aircon_qr")),
      ),
      body: ReaderWidget(
        isMultiScan: true,
        codeFormat: Format.matrixCodes,
        tryHarder: true,
        tryInverted: true,
        tryDownscale: true,
        showGallery: false,
        showToggleCamera: false,
        onMultiScan: (results) {
          if (_finished) return;
          final imei = _tryParseAirconImei(results);
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
*/
