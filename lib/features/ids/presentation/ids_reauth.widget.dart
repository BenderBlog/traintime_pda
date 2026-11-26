// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:watermeter/generated/translations.g.dart';

/// The dialog for IDS 2FA
Future<IdsCodeSubmission?> showIdsReauthDialog(
  BuildContext context,
  IdsCodeDelivery delivery,
) => showDialog<IdsCodeSubmission>(
  context: context,
  barrierDismissible: false,
  builder: (context) => _IdsReauthDialog(delivery: delivery),
);

class _IdsReauthDialog extends StatefulWidget {
  const _IdsReauthDialog({required this.delivery});

  final IdsCodeDelivery delivery;

  @override
  State<_IdsReauthDialog> createState() => _IdsReauthDialogState();
}

class _IdsReauthDialogState extends State<_IdsReauthDialog> {
  final _codeController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _trustDevice = false;
  bool _sending = false;
  late IdsCodeType _codeType;
  late IdsCodeDelivery _delivery;
  String? _notice;
  String? _error;

  /// To avoid that user submit the captcha from the previous code type after switching to the other type.
  bool _methodChanged = false;

  @override
  void initState() {
    super.initState();
    _delivery = widget.delivery;
    _codeType = _delivery.codeType;
    _methodChanged = !_delivery.sent;
    _notice = _delivery.message;
    _startCountdown(_delivery.retryAfter.inSeconds);
  }

  Future<void> _sendCode() async {
    final send = _delivery.sendCode;
    if (send == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final delivery = await send(_codeType);
      if (!mounted) return;
      setState(() {
        _delivery = delivery;
        _methodChanged = false;
        final recipient = delivery.maskedRecipient;
        _notice = recipient == null
            ? delivery.message
            : '${delivery.message ?? context.t.ids.codeSent}（$recipient）';
      });
      _startCountdown(delivery.retryAfter.inSeconds);
    } catch (_) {
      if (mounted) setState(() => _error = context.t.ids.codeSendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    _secondsRemaining = seconds;
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

  void _submit() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = context.t.ids.codeRequired);
      return;
    }
    Navigator.of(context).pop((code: code, trustDevice: _trustDevice));
  }

  void _changeCodeType(IdsCodeType? value) {
    if (value == null || value == _codeType) return;
    _timer?.cancel();
    _codeController.clear();
    setState(() {
      _codeType = value;
      _methodChanged = true;
      _secondsRemaining = 0;
      _notice = null;
      _error = null;
    });
  }

  String _codeTypeName(IdsCodeType type) => switch (type) {
    IdsCodeType.sms => context.t.ids.smsCode,
    IdsCodeType.enterpriseWechat => context.t.ids.wechatCode,
  };

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notice = _methodChanged
        ? null
        : _notice ??
              (_delivery.codeRejected
                  ? context.t.ids.codeInvalid
                  : context.t.ids.codeSent);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(context.t.ids.mfaTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<IdsCodeType>(
                  initialValue: _codeType,
                  decoration: InputDecoration(
                    labelText: context.t.ids.mfaMethodTitle,
                  ),
                  items: IdsCodeType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_codeTypeName(type)),
                        ),
                      )
                      .toList(),
                  onChanged: _sending ? null : _changeCodeType,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeController,
                  enabled: !_sending && !_methodChanged,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: InputDecoration(
                    labelText: _codeTypeName(_codeType),
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed:
                      _sending ||
                          _secondsRemaining > 0 ||
                          _delivery.sendCode == null
                      ? null
                      : _sendCode,
                  child: Text(
                    _secondsRemaining > 0
                        ? context.t.ids.resendCountdown(
                            seconds: _secondsRemaining,
                          )
                        : context.t.ids.sendCode,
                  ),
                ),
                if (notice != null) ...[
                  const SizedBox(height: 8),
                  Text(notice, style: Theme.of(context).textTheme.bodySmall),
                ],
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _trustDevice,
                  onChanged: _sending
                      ? null
                      : (value) =>
                            setState(() => _trustDevice = value ?? false),
                  title: Text(context.t.ids.trustDevice),
                  subtitle: Text(context.t.ids.trustDeviceHint),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _sending ? null : () => Navigator.of(context).pop(),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: _sending || _methodChanged ? null : _submit,
            child: Text(context.t.ids.submit),
          ),
        ],
      ),
    );
  }
}
