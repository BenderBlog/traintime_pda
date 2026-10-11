// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:synchronized/synchronized.dart';
import 'package:watermeter/repository/preference.dart' as preference;

final _fingerprintLock = Lock();

String generateIDSBrowserFingerprint([Random? random]) {
  final source = random ?? Random.secure();
  return List<int>.generate(16, (_) => source.nextInt(256))
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
}

Future<String> getOrCreateIDSBrowserFingerprint() {
  return _fingerprintLock.synchronized(() async {
    final stored = preference.getString(
      preference.Preference.idsBrowserFingerprint,
    );
    if (RegExp(r'^[0-9A-F]{32}$').hasMatch(stored)) return stored;

    final generated = generateIDSBrowserFingerprint();
    await preference.setString(
      preference.Preference.idsBrowserFingerprint,
      generated,
    );
    return generated;
  });
}
