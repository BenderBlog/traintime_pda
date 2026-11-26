// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:pda_repository/pda_repository.dart';
import 'package:signals/signals.dart';

import 'ids_credentials.model.dart';
import 'ids_credentials.store.dart';
import 'ids_snapshot.model.dart';

/// The use cases of ids.
/// 
/// Network interface implementation and Secure store should be injected manually.
/// Because the feature need to be initialized before app start. 
/// So it is impossible for get dependencies from context.
/// 
/// ---
/// 
/// This implementation is totally different from the one in v1. 
/// 
/// 1. [authorizeService] support parallel process, not serial process.
/// 2. [signIn] and [authorizeService] are separate operations. 
///   - First try to authorize with the existing session. 
///   - If the session is invalid, log in to IDS and then re-authorize the target service.
/// 3. Concurrently restore multiple invalid session
/// 4. When app is starting, [restore] will read the saved credential. 
/// Having get credential does not mean credential is valid.
/// 5. IDS Tickets will be put into secure storage.
/// 6. Status will be highly cohesive. The outside only can access to read-only snapshot.
/// 7. The use case discards expired asynchronous results based on the version identifier of the account operation
/// On exit, it cleans up network sessions and saved credentials, and coordinates ongoing credential writes.
/// 8. More typed exception will be returned than the implementation of v1.
final class IdsUseCase {
  IdsUseCase(this._store, this._network);

  final SecureIdsCredentialsStore _store;
  final IdsNetworkRepository _network;
  final Signal<IdsSnapshot> _state = signal(
    const IdsSnapshot(IdsStatus.signedOut),
  );
  /// Get the read-only reactive state of ids feature
  ReadonlySignal<IdsSnapshot> get state => _state.readonly();
  /// Get the snapshot of the reactive state at the moment
  IdsSnapshot get snapshot => _state.value;
  /// Used to record the generation of the operation.
  /// 
  /// When signin, signout and restore, the state updating will be stopped 
  /// if the previous operation finds the generation having changed.
  int _epoch = 0;
  /// Used to represent the version of session.
  /// 
  /// Identifies the current session generation. Changes when signing in,
  /// signing out, or successfully recovering a session, so an authorization
  /// can tell whether another operation has already refreshed its session.
  int _sessionVersion = 0;

  /// The shared login task used to recover an expired session, if one is
  /// recorded. Concurrent authorizations can await it instead of logging in
  /// separately. Clearing this reference does not cancel the task.
  Future<void>? _recovery;

  /// The most recently started credentials write. Sign-out waits for it before
  /// clearing the store, so that write cannot restore credentials after cleanup.
  Future<void>? _pendingWrite;

  /// The current sign-out task. Later sign-ins, authorizations, and sign-outs
  /// wait for it before accessing or clearing the session.
  Future<void>? _logout;

  /// The current sign-in task. Authorizations wait for it, and a subsequent
  /// sign-in waits for the previous task before starting its network login.
  Future<void>? _signingIn;

  /// Authorization tasks currently tracked by this use case. A new sign-in
  /// waits for the tasks already in this set before starting its network login.
  /// Clearing the set does not cancel those tasks.
  final _authorizations = <Future<void>>{};

  /// The attached handler for interactive IDS challenges, such as a slider or
  /// two-factor authentication. An interaction passed to an operation takes
  /// precedence over this handler.
  IdsInteraction? _interaction;

  /// @docImport 'package:watermeter/features/ids/widgets/ids_interaction.widget.dart';
  /// 
  /// Used for IDS feature registering an interaction for user. 
  /// And the return Function is used to cancel the passed [IdsInteraction].
  /// 
  /// It can be treated as the abstract entity of [IdsInteractionHost]. 
  /// When the auto login fails, IDS feature will try to popup the dialog of slider and 2FA by the [IdsInteraction].
  void Function() attachInteraction(IdsInteraction interaction) {
    _interaction = interaction;
    return () {
      if (identical(_interaction, interaction)) _interaction = null;
    };
  }

  /// Used for restoring the last saved [IdsCredentials] for secure storage and update IDS feature's state.
  /// 
  /// The restored contents only include account information. The restore logic of cookie is in PdaNetwork layer.
  Future<void> restore() async {
    // Record the epoch number for recognizing the outdate operation
    final epoch = ++_epoch;
    // Set state
    _emit(const IdsSnapshot(IdsStatus.authenticating));
    try {
      final saved = await _store.read();
      if (epoch != _epoch) return;
      _emit(
        saved == null
            ? const IdsSnapshot(IdsStatus.signedOut)
            : IdsSnapshot(
                IdsStatus.credentialsAvailable,
                username: saved.username,
              ),
      );
    } catch (error) {
      if (epoch != _epoch) return;
      _emit(IdsSnapshot(IdsStatus.error, error: error));
      rethrow;
    }
  }

  /// `signIn()` can be passed [IdsInteraction] or not. 
  /// 
  /// When the interaction is not null, the 2FA and the slider will be triggered by this.
  Future<void> signIn(
    IdsCredentials credentials, {
    IdsInteraction? interaction,
  }) => _startSignIn(credentials, interaction: interaction);

  /// The retry entry for the wrong password.
  Future<void> reauthenticate(IdsCredentials credentials) {
    if (snapshot.status != IdsStatus.credentialsAvailable ||
        snapshot.username != credentials.username) {
      return Future.error(StateError('IDS account is unavailable'));
    }
    return _startSignIn(credentials, keepPage: true);
  }

  Future<void> clearLoginCache() => _network.clear();

  /// Register and manage the ongoing signin.
  Future<void> _startSignIn(
    IdsCredentials credentials, {
    IdsInteraction? interaction,
    bool keepPage = false,
  }) {
    final signIn = _signIn(
      credentials,
      previousLogin: _signingIn,
      previousRecovery: _recovery,
      previousAuthorizations: _authorizations.toList(),
      interaction: interaction,
      keepPage: keepPage,
    );
    _signingIn = signIn;
    return signIn.whenComplete(() {
      if (identical(_signingIn, signIn)) _signingIn = null;
    });
  }

  Future<void> _signIn(
    IdsCredentials credentials, {
    Future<void>? previousLogin,
    Future<void>? previousRecovery,
    required List<Future<void>> previousAuthorizations,
    IdsInteraction? interaction,
    required bool keepPage,
  }) async {
    final epoch = ++_epoch;
    ++_sessionVersion;
    _recovery = null;
    var authenticated = false;
    _emit(
      IdsSnapshot(
        keepPage ? IdsStatus.credentialsAvailable : IdsStatus.authenticating,
        username: credentials.username,
      ),
    );
    try {
      await _logout;
      if (epoch != _epoch) return;
      for (final previous in [
        previousLogin,
        previousRecovery,
        ...previousAuthorizations,
      ]) {
        if (previous != null) {
          try {
            await previous;
          } catch (_) {}
          if (epoch != _epoch) return;
        }
      }
      await _network.login(
        credentials.username,
        credentials.password,
        interaction: interaction ?? _interaction ?? const IdsInteraction(),
      );
      authenticated = true;
      if (epoch != _epoch) return;
      final write = _store.write(credentials);
      _pendingWrite = write;
      await write;
      if (epoch != _epoch) return;
      _emit(IdsSnapshot(IdsStatus.ready, username: credentials.username));
    } catch (error) {
      if (epoch != _epoch) return;
      if (authenticated) {
        try {
          await _network.clear();
        } catch (_) {
          // Keep the persistence error as the reported failure.
        }
      }
      if (epoch != _epoch) return;
      _emit(
        IdsSnapshot(
          keepPage ? IdsStatus.credentialsAvailable : IdsStatus.error,
          username: credentials.username,
          error: error,
        ),
      );
      rethrow;
    }
  }

  Future<void> authorizeService(Uri service, {IdsInteraction? interaction}) {
    final result = _authorizeService(service, interaction: interaction);
    _authorizations.add(result);
    return result.whenComplete(() => _authorizations.remove(result));
  }

  Future<void> _authorizeService(
    Uri service, {
    IdsInteraction? interaction,
  }) async {
    final epoch = _epoch;
    final sessionVersion = _sessionVersion;
    final activeInteraction =
        interaction ?? _interaction ?? const IdsInteraction();
    try {
      await _logout;
      if (epoch != _epoch) return;
      await _signingIn;
      if (epoch != _epoch) return;
      await _recovery;
      if (epoch != _epoch) return;
      try {
        await _network.authorize(service, interaction: activeInteraction);
      } on IdsSessionExpired {
        if (epoch != _epoch) return;
        if (sessionVersion == _sessionVersion) {
          final recovery = _recovery ??= _loginSavedCredentials(
            epoch,
            activeInteraction,
          );
          try {
            await recovery;
          } finally {
            if (identical(_recovery, recovery)) _recovery = null;
          }
        }
        if (epoch != _epoch) return;
        await _network.authorize(service, interaction: activeInteraction);
      }
      if (epoch != _epoch) return;
      if (snapshot.status != IdsStatus.ready) {
        _emit(IdsSnapshot(IdsStatus.ready, username: snapshot.username));
      }
    } catch (_) {
      if (epoch != _epoch) return;
      rethrow;
    }
  }

  Future<void> _loginSavedCredentials(
    int epoch,
    IdsInteraction interaction,
  ) async {
    final credentials = await _store.read();
    if (epoch != _epoch) return;
    if (credentials == null) {
      throw StateError('IDS credentials are unavailable');
    }
    try {
      await _network.login(
        credentials.username,
        credentials.password,
        interaction: interaction,
      );
    } on IdsCredentialsRejected catch (error) {
      if (epoch == _epoch) {
        _emit(
          IdsSnapshot(
            IdsStatus.credentialsAvailable,
            username: credentials.username,
            error: error,
          ),
        );
      }
      rethrow;
    }
    if (epoch == _epoch) ++_sessionVersion;
  }

  Future<void> signOut() {
    final epoch = ++_epoch;
    ++_sessionVersion;
    _recovery = null;
    _signingIn = null;
    _authorizations.clear();
    final previous = _logout;
    final logout = _signOut(epoch, previous);
    _logout = logout;
    return logout.then((_) {
      if (identical(_logout, logout)) _logout = null;
    });
  }

  Future<void> _signOut(int epoch, Future<void>? previous) async {
    try {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {}
      }
      await _network.clear();
      try {
        await _pendingWrite;
      } catch (_) {}
      await _store.clear();
      if (epoch == _epoch) _emit(const IdsSnapshot(IdsStatus.signedOut));
    } catch (_) {
      rethrow;
    }
  }

  void _emit(IdsSnapshot value) {
    _state.value = value;
  }

  void dispose() {
    ++_epoch;
    ++_sessionVersion;
    _recovery = null;
    _interaction = null;
    _state.dispose();
  }
}
