// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:pda_repository/pda_repository.dart';

/// Shared by IDS and remote sources using the same campus SSO cookies.
final class IdsHttpSession {
  IdsHttpSession(this._store, {Dio Function()? dioFactory})
    : _dioFactory = dioFactory ?? Dio.new {
    _newJar();
  }

  final IdsSessionStore _store;
  final Dio Function() _dioFactory;
  final _clients = <Dio>[];
  late PersistCookieJar _cookies;
  int _generation = 0;
  bool _closed = false;

  /// Serially clear cookie jar
  Future<void> _clearing = Future.value();

  void _newJar() {
    final generation = _generation;
    _cookies = PersistCookieJar(
      persistSession: true,
      storage: _IdsCookieStorage(_store, () => generation == _generation),
    );
  }

  /// Clients are invalidated by [clear]; remote sources create a new one afterward.
  Future<Dio> createClient() async {
    // Clear all the pending jar to clear
    Future<void> clearing;
    do {
      clearing = _clearing;
      await clearing;
    } while (!identical(clearing, _clearing));

    if (_closed) throw StateError('IDS session is closed');

    final client = _dioFactory();
    client.interceptors.insert(0, CookieManager(_cookies));
    client.options.followRedirects = false;
    client.options.contentType = Headers.formUrlEncodedContentType;
    client.options.headers[HttpHeaders.userAgentHeader] =
        'Mozilla/5.0 XDYou/2.0';
    client.options.connectTimeout = const Duration(seconds: 10);
    client.options.receiveTimeout = const Duration(seconds: 30);
    client.options.validateStatus = (status) => status != null && status < 500;

    _clients.add(client);
    return client;
  }

  Future<void> clear() {
    ++_generation;
    _closeClients();
    final clear = _clearing.catchError((Object _) {}).then((_) => _clearJar());
    _clearing = clear;
    clear.catchError((Object _) {});
    return clear;
  }

  Future<void> _clearJar() async {
    try {
      await _cookies.deleteAll();
    } finally {
      _newJar();
    }
  }

  void close() {
    _closed = true;
    ++_generation;
    _closeClients();
  }

  void _closeClients() {
    for (final client in _clients) {
      client.close(force: true);
    }
    _clients.clear();
  }
}

final class _IdsCookieStorage extends Storage {
  _IdsCookieStorage(this._store, this._isCurrent);

  final IdsSessionStore _store;

  /// The checker function to make sure the cookies stay in one session.
  ///
  /// Mainly used for avoiding that the previous request result reaches later
  /// and the cookie is wrote with the previous request result after logout or
  /// switch account.
  final bool Function() _isCurrent;
  Future<void> _pending = Future.value();

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String name) => _store.read('ids.session.$name');

  @override
  Future<void> write(String name, String value) {
    final write = _pending.then((_) async {
      if (_isCurrent()) await _store.write('ids.session.$name', value);
    });
    _pending = write.catchError((Object _) {});
    return write;
  }

  @override
  Future<void> delete(String name) {
    final deletion = _pending.then((_) async {
      if (_isCurrent()) await _store.delete('ids.session.$name');
    });
    _pending = deletion.catchError((Object _) {});
    return deletion;
  }

  @override
  Future<void> deleteAll(List<String> names) async {
    await _pending;
    for (final name in names) {
      await _store.delete('ids.session.$name');
    }
  }
}
