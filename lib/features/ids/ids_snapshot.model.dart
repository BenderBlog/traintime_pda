// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

enum IdsStatus { signedOut, credentialsAvailable, authenticating, ready, error }

final class IdsSnapshot {
  const IdsSnapshot(this.status, {this.username, this.error});

  final IdsStatus status;
  final String? username;
  final Object? error;
}
