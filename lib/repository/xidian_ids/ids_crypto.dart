// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Shared AES encryption utilities for IDS (统一认证服务).
// Used by both slider captcha payload encryption and recheck password encryption.

import 'dart:math';
import 'dart:typed_data';
import 'package:encrypter_plus/encrypter_plus.dart' as encrypt;

class IdsCrypto {
  static const String aesChars =
      "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678";
  static const int _blockSize = 16;
  static final Random _random = Random.secure();

  /// Generate a random string of [length] characters from [aesChars].
  ///
  /// Character set excludes easily confused characters: I/L/O/i/l/o/0/1/9.
  static String randomString(int length) {
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => aesChars.codeUnitAt(_random.nextInt(aesChars.length)),
      ),
    );
  }

  /// IDS standard AES-CBC password encryption.
  ///
  /// Plaintext = randomString(64) + [plainText]
  /// Key = [keyBytes] (typically 16 bytes, UTF-8 encoded)
  /// IV = randomString(16), UTF-8 encoded
  /// Padding = PKCS7
  /// Output = Base64(ciphertext), IV is NOT included.
  ///
  /// Used by:
  /// - Slider captcha: key from image tail bytes
  /// - Recheck: key from WIS_PER_ENC cookie
  static String encryptPassword(String plainText, Uint8List keyBytes) {
    final ivStr = randomString(_blockSize);
    final nonce = randomString(_blockSize * 4);
    final plain = nonce + plainText;

    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromUtf8(ivStr);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    return encrypter.encrypt(plain, iv: iv).base64;
  }
}
