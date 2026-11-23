// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

final class UpdateRelease {
  UpdateRelease({
    required this.code,
    required List<String> changes,
    required this.iosUrl,
    required this.androidUrl,
    required this.githubUrl,
  }) : changes = List.unmodifiable(changes);

  final String code;
  final List<String> changes;
  final String iosUrl;
  final String androidUrl;
  final String githubUrl;
}
