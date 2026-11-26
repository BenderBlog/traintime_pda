// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypter_plus/encrypter_plus.dart' as crypto;

String encryptIdsPassword(String value, String salt) {
  return _encryptBytes(
    'xidianscriptsxduxidianscriptsxduxidianscriptsxduxidianscriptsxdu$value',
    utf8.encode(salt),
  );
}

String _encryptBytes(String value, List<int> key) {
  final data = utf8.encode(value);
  final padding = 16 - data.length % 16;
  final padded = Uint8List.fromList([
    ...data,
    ...List.filled(padding, padding),
  ]);
  final aes = crypto.AES(
    crypto.Key(Uint8List.fromList(key)),
    mode: crypto.AESMode.cbc,
    padding: null,
  );
  return crypto.Encrypter(aes)
      .encryptBytes(padded, iv: crypto.IV.fromUtf8('xidianscriptsxdu'))
      .base64;
}

String encryptIdsSlider(String value, List<int> key) {
  const chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678';
  final random = Random.secure();
  final nonce = List.generate(
    80,
    (_) => chars[random.nextInt(chars.length)],
  ).join();
  final aes = crypto.AES(
    crypto.Key(Uint8List.fromList(key)),
    mode: crypto.AESMode.cbc,
  );
  return crypto.Encrypter(aes)
      .encrypt(
        '${nonce.substring(0, 64)}$value',
        iv: crypto.IV.fromUtf8(nonce.substring(64)),
      )
      .base64;
}
