// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

enum PasswordType { physicsExperiment, sport, electricity, schoolnet }

class NoPasswordException implements Exception {
  final PasswordType type;

  const NoPasswordException({required this.type});
}
