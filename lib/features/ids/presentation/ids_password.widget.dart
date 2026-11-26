// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../ids.case.dart';
import '../ids_credentials.model.dart';
import '../ids_snapshot.model.dart';
import 'ids_login_error.dart';

/// @docImport 'package:watermeter/core/presentation/app_shell/app_shell.dart';
///
/// The password input dialog.
///
/// The dialog will be pushed when IDS ticket is rejected and the state of IDS feature is [IdsStatus.credentialsAvailable].
///
/// Mostly the last Widget in the navigator is [AppShell].
class IdsPasswordDialog extends StatefulWidget {
  const IdsPasswordDialog({
    super.key,
    required this.feature,
    required this.username,
  });
  final IdsUseCase feature;
  final String username;

  @override
  State<IdsPasswordDialog> createState() => _IdsPasswordDialogState();
}

class _IdsPasswordDialogState extends State<IdsPasswordDialog> {
  final _password = TextEditingController();
  late final void Function() _unsubscribe;
  bool _working = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _unsubscribe = widget.feature.state.subscribe((snapshot) {
      if (snapshot.status != IdsStatus.signedOut) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final route = ModalRoute.of(context);
        if (route != null && route.isActive) {
          Navigator.of(context).removeRoute(route);
        }
      });
      WidgetsBinding.instance.scheduleFrame();
    });
  }

  Future<void> _submit() async {
    if (_password.text.isEmpty || _working) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await widget.feature.reauthenticate(
        IdsCredentials(widget.username, _password.text),
      );
      if (mounted) Navigator.pop(context);
    } catch (failure) {
      if (mounted) {
        setState(() {
          _working = false;
          _error = idsLoginErrorMessage(context, failure);
        });
      }
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_working,
    child: AlertDialog(
      title: Text(context.t.ids.reauthenticate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.t.ids.reauthenticateMessage),
          TextField(
            controller: _password,
            autofocus: true,
            obscureText: true,
            enabled: !_working,
            decoration: InputDecoration(
              labelText: context.t.ids.password,
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _working ? null : () => Navigator.pop(context),
          child: Text(context.t.common.cancel),
        ),
        FilledButton(
          onPressed: _working ? null : _submit,
          child: Text(context.t.ids.login),
        ),
      ],
    ),
  );
}
