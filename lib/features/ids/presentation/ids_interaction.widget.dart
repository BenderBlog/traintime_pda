// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:pda_repository/pda_repository.dart';

import '../ids.case.dart';
import '../ids_snapshot.model.dart';
import 'ids_password.widget.dart';
import 'ids_reauth.widget.dart';
import 'ids_slider.widget.dart';

/// Keeps IDS challenges available while either route is visible.
final class IdsInteractionHost extends StatefulWidget {
  const IdsInteractionHost({
    super.key,
    required this.feature,
    required this.child,
  });

  final IdsUseCase feature;
  final Widget child;

  @override
  State<IdsInteractionHost> createState() => _IdsInteractionHostState();
}

final class _IdsInteractionHostState extends State<IdsInteractionHost> {
  /// The detach method for interaction from IDS feature
  late void Function() _detachInteraction;

  /// The the method to cancel subscription from Signals
  void Function()? _unsubscribe;
  bool _askingPassword = false;

  /// Keeps verification dialogs in sequence so only one is shown at a time.
  Future<void> _prompt = Future.value();

  @override
  void initState() {
    super.initState();
    _attach();
  }

  void _attach() {
    _detachInteraction = widget.feature.attachInteraction(
      IdsInteraction(solveSlider: _solveSlider, enterCode: _enterCode),
    );
    _unsubscribe = widget.feature.state.subscribe(_onSnapshot);
  }

  @override
  void didUpdateWidget(covariant IdsInteractionHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.feature, oldWidget.feature)) {
      _detachInteraction();
      _unsubscribe?.call();
      _attach();
    }
  }

  /// Use the reactive state from IDS feature to listen if there is some authorization issue.
  void _onSnapshot(IdsSnapshot snapshot) {
    if (_askingPassword ||
        snapshot.error is! IdsCredentialsRejected ||
        snapshot.status != IdsStatus.credentialsAvailable ||
        snapshot.username == null) {
      return;
    }
    _askingPassword = true;
    final feature = widget.feature;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted &&
          identical(feature, widget.feature) &&
          feature.snapshot.status == IdsStatus.credentialsAvailable &&
          feature.snapshot.error is IdsCredentialsRejected &&
          feature.snapshot.username == snapshot.username) {
        await _askPassword(snapshot.username!);
      }
      _askingPassword = false;
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Popup the dialog for the correct password.
  Future<void> _askPassword(String username) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        IdsPasswordDialog(feature: widget.feature, username: username),
  );

  Future<List<IdsSliderPoint>?> _solveSlider(
    Uint8List background,
    Uint8List piece,
    bool retry,
  ) async =>
      mounted ? showIdsSlider(context, background, piece, retry: retry) : null;

  Future<IdsCodeSubmission?> _enterCode(IdsCodeDelivery delivery) {
    final result = _prompt.then(
      (_) => mounted ? showIdsReauthDialog(context, delivery) : null,
    );
    _prompt = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  @override
  void dispose() {
    _detachInteraction();
    _unsubscribe?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
