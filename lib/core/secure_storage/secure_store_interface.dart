// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

abstract interface class SecureStoreInterface {
  /// Returns null only when the key does not exist. Platform failures throw.
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}
