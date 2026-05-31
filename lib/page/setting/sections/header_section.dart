// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

part of '../setting_sections.dart';

class SettingHeader extends StatelessWidget {
  const SettingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: Platform.isIOS || Platform.isMacOS || Platform.isAndroid
                ? "XDYou"
                : 'Traintime PDA',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\nWritten by BenderBlog Rodriguez and contributors',
          ),
        ],
      ),
    ).padding(horizontal: 8.0);
  }
}
