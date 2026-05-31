// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

part of '../setting_sections.dart';

Widget buildSettingSectionTitle(String text) => Text(
  text,
  style: const TextStyle(fontWeight: FontWeight.bold),
).padding(bottom: 8).center();
