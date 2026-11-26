// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/shared/widgets/app_icon.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../ids.case.dart';
import '../ids_credentials.model.dart';
import 'ids_interaction.widget.dart';
import '../ids_snapshot.model.dart';
import 'ids_login_error.dart';

final class IdsGate extends StatefulWidget {
  const IdsGate({
    super.key,
    required this.feature,
    required this.targetBuilder,
  });

  final IdsUseCase feature;
  final WidgetBuilder targetBuilder;

  @override
  State<IdsGate> createState() => _IdsGateState();
}

final class _IdsGateState extends State<IdsGate> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _working = false;
  bool _clearing = false;
  bool _passwordHidden = true;

  @override
  void initState() {
    super.initState();
    _username.text = widget.feature.snapshot.username ?? '';
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(IdsGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.feature, oldWidget.feature)) {
      if (_username.text.isEmpty) {
        _username.text = widget.feature.snapshot.username ?? '';
      }
    }
  }

  Future<void> _login() async {
    if (_working || _clearing) return;
    final username = _username.text.trim();
    final password = _password.text;
    if (username.isEmpty || password.isEmpty) return;
    setState(() => _working = true);
    try {
      await widget.feature.signIn(IdsCredentials(username, password));
      _password.clear();
    } catch (_) {
      // The feature snapshot carries the user-facing failure.
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _clearCache() async {
    if (_working || _clearing) return;
    setState(() => _clearing = true);
    try {
      await widget.feature.clearLoginCache();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.t.ids.cacheCleared)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.t.ids.cacheClearFailed)));
      }
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) => SignalBuilder(
    builder: (context) => _buildPage(context, widget.feature.state.value),
  );

  Widget _buildPage(BuildContext context, IdsSnapshot snapshot) {
    if (snapshot.status == IdsStatus.ready ||
        snapshot.status == IdsStatus.credentialsAvailable) {
      return widget.targetBuilder(context);
    }
    if (snapshot.status == IdsStatus.authenticating && !_working) {
      return IdsInteractionHost(
        feature: widget.feature,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final size = MediaQuery.sizeOf(context);
    final wide = size.width / size.height > 1 && size.width > 840;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _username,
            decoration: _inputDecoration(
              iconData: MingCuteIcons.mgc_user_3_fill,
              hintText: context.t.ids.username,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: _passwordHidden,
            decoration: _inputDecoration(
              iconData: MingCuteIcons.mgc_safe_lock_fill,
              hintText: context.t.ids.password,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordHidden ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _passwordHidden = !_passwordHidden),
              ),
            ),
            onSubmitted: (_) => _login(),
          ),
          if (snapshot.status == IdsStatus.error) ...[
            const SizedBox(height: 12),
            Text(idsLoginErrorMessage(context, snapshot.error)),
          ],
          SizedBox(height: wide ? 16 : 32),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              maximumSize: const Size(double.infinity, 64),
            ),
            onPressed: _working || _clearing ? null : _login,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_working) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  _working ? context.t.ids.loggingIn : context.t.ids.login,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),  
          SizedBox(height: wide ? 8 : 16),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: _working || _clearing ? null : _clearCache,
                child: Text(context.t.ids.clearCache),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  legacy.MaterialPageRoute<void>(
                    builder: (context) => TalkerScreen(
                      talker: context.read<Talker>(),
                      theme: TalkerScreenTheme.fromTheme(
                        legacy.Theme.of(context),
                      ),
                    ),
                  ),
                ),
                child: Text(context.t.ids.viewNetworkActivity),
              ),
            ],
          ),
        ],
      ),
    );
    return IdsInteractionHost(
      feature: widget.feature,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
            left: wide ? size.width * .25 : 32,
            right: wide ? size.width * .25 : 32,
            top: kToolbarHeight,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: wide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppIconWidget(),
                            const SizedBox(width: 48),
                            Expanded(child: content),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 32),
                              child: AppIconWidget(),
                            ),
                            content,
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData iconData,
    required String hintText,
    Widget? suffixIcon,
  }) => InputDecoration(
    prefixIcon: Icon(iconData),
    hintText: hintText,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}
