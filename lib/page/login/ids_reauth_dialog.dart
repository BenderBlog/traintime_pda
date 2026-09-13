// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/repository/ids_session/ids_auth_protocol.dart';
import 'package:watermeter/repository/ids_session/ids_reauth_client.dart';

Future<Uri> showIDSReAuthDialog(
  BuildContext context,
  IDSReAuthClient client,
) async {
  final result = await showDialog<Object>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _IDSReAuthDialog(client: client),
  );
  if (result is Uri) return result;
  if (result is Exception) throw result;
  throw const IDSReAuthCancelledException();
}

class _IDSReAuthDialog extends StatefulWidget {
  const _IDSReAuthDialog({required this.client});

  final IDSReAuthClient client;

  @override
  State<_IDSReAuthDialog> createState() => _IDSReAuthDialogState();
}

class _IDSReAuthDialogState extends State<_IDSReAuthDialog> {
  final _codeController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _trustDevice = false;
  bool _sending = false;
  bool _submitting = false;
  IDSReAuthCodeType _codeType = IDSReAuthCodeType.sms;
  String? _notice;
  String? _error;

  String _t(String key) => FlutterI18n.translate(context, key);

  Future<void> _sendCode() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final delivery = await widget.client.sendCode(codeType: _codeType);
      if (!mounted) return;
      final recipient =
          delivery.maskedMobile ?? widget.client.recipientDescription;
      setState(() {
        _notice = recipient == null
            ? delivery.message
            : '${delivery.message}（$recipient）';
      });
      _startCountdown(delivery.retryAfter.inSeconds);
    } on DioException {
      if (mounted) {
        setState(() => _error = _t('login.second_factor.network_error'));
      }
    } on IDSReAuthExpiredException catch (error) {
      if (mounted) Navigator.of(context).pop(error);
    } on IDSProtocolException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsRemaining = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  Future<void> _submit() async {
    if (_codeController.text.trim().isEmpty) {
      setState(() => _error = _t('login.second_factor.empty_code'));
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final uri = await widget.client.submitCode(
        codeType: _codeType,
        code: _codeController.text,
        trustDevice: _trustDevice,
      );
      if (mounted) Navigator.of(context).pop(uri);
    } on IDSReAuthCodeRejectedException catch (error) {
      _codeController.clear();
      if (mounted) setState(() => _error = error.message);
    } on IDSReAuthExpiredException catch (error) {
      if (mounted) Navigator.of(context).pop(error);
    } on DioException {
      if (mounted) {
        setState(() => _error = _t('login.second_factor.network_error'));
      }
    } on IDSProtocolException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _changeCodeType(IDSReAuthCodeType? value) {
    if (value == null || value == _codeType) return;
    _timer?.cancel();
    _codeController.clear();
    setState(() {
      _codeType = value;
      _secondsRemaining = 0;
      _notice = null;
      _error = null;
    });
  }

  String _codeTypeName(IDSReAuthCodeType type) => switch (type) {
    IDSReAuthCodeType.sms => _t('login.second_factor.sms'),
    IDSReAuthCodeType.enterpriseWechat => _t(
      'login.second_factor.enterprise_wechat',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final busy = _sending || _submitting;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(_t('login.second_factor.title')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Text(_t('login.second_factor.description')),
              //const SizedBox(height: 16),
              DropdownButtonFormField<IDSReAuthCodeType>(
                initialValue: _codeType,
                decoration: InputDecoration(
                  labelText: _t('login.second_factor.method'),
                ),
                items: IDSReAuthCodeType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_codeTypeName(type)),
                      ),
                    )
                    .toList(),
                onChanged: busy ? null : _changeCodeType,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                enabled: !busy,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                decoration: InputDecoration(
                  labelText: _codeTypeName(_codeType),
                  errorText: _error,
                ),
                onSubmitted: (_) => busy ? null : _submit(),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: busy || _secondsRemaining > 0 ? null : _sendCode,
                child: Text(
                  _secondsRemaining > 0
                      ? _t('login.second_factor.resend_countdown').replaceFirst(
                          '{seconds}',
                          _secondsRemaining.toString(),
                        )
                      : _t('login.second_factor.send_code'),
                ),
              ),
              if (_notice != null) ...[
                const SizedBox(height: 8),
                Text(_notice!, style: Theme.of(context).textTheme.bodySmall),
              ],
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _trustDevice,
                onChanged: busy
                    ? null
                    : (value) => setState(() => _trustDevice = value ?? false),
                title: Text(_t('login.second_factor.trust_device')),
                subtitle: Text(_t('login.second_factor.trust_device_hint')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy
                ? null
                : () => Navigator.of(
                    context,
                  ).pop(const IDSReAuthCancelledException()),
            child: Text(_t('cancel')),
          ),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_t('confirm')),
          ),
        ],
      ),
    );
  }
}
