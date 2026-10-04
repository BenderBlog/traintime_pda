// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:watermeter/controller/aircon_controller.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
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

class AirconImeiPage extends StatefulWidget {
  const AirconImeiPage({super.key});

  @override
  State<AirconImeiPage> createState() => _AirconImeiPageState();
}

class _AirconImeiPageState extends State<AirconImeiPage> {
  late final TextEditingController _controller = TextEditingController(
    text: preference.getString(preference.Preference.airconImei),
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    if (!_canUseCameraScanner) {
      showToast(
        context: context,
        msg: context.t.setting.airconCameraUnavailable,
      );
      return;
    }

    final imei = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (context) => const _AirconImeiScannerPage()),
    );
    if (!mounted || imei == null || imei.isEmpty) return;
    _controller.text = imei;
    setState(() => _error = null);
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
        showToast(context: context, msg: context.t.setting.airconImeiInvalid);
        return;
      }

      _controller.text = imei;
      setState(() => _error = null);
    } catch (e) {
      if (!mounted) return;
      showToast(context: context, msg: context.t.setting.airconImeiInvalid);
    }
  }

  Future<void> _persist({bool clear = false}) async {
    if (_saving) return;
    if (!clear && AirconController.tryParseImei(_controller.text) == null) {
      setState(() => _error = context.t.setting.airconImeiInvalid);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (clear) {
        await AirconController.i.clearImei();
      } else {
        await AirconController.i.updateImei(_controller.text);
      }
      if (!mounted) return;
      showToast(
        context: context,
        msg: context.t.resolveKey(
          clear ? 'setting.aircon_imei_cleared' : 'setting.aircon_imei_saved',
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.t.common.errorDetected);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(context.t.setting.airconImeiTitle)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                24,
                16,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                TextField(
                  controller: _controller,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _persist(),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    labelText: context.t.setting.airconImei,
                    border: const OutlineInputBorder(),
                    errorText: _error,
                    errorMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_canUseCameraScanner)
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _scanQrCode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(context.t.setting.scanAirconQr),
                      ),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickQrCodeImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(context.t.setting.pickAirconQrImage),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : () => _persist(),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.t.setting.editor.save),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _saving ? null : () => _persist(clear: true),
                  child: Text(context.t.setting.airconImeiClear),
                ),
              ],
            ),
          ),
        ),
      ),
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
      appBar: AppBar(title: Text(context.t.setting.scanAirconQr)),
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
              msg: context.t.setting.airconImeiInvalid,
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
