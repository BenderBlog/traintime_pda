// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

/// The account and password in each IDS instance.
final class IdsCredentials {
  IdsCredentials(this.username, this.password) {
    if (username.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('IDS credentials must be complete');
    }
  }

  final String username;
  final String password;
}
