// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/setting/setting_header.dart';

class SectionSettingScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget items;
  const SectionSettingScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          SettingHeader(title: title!, subtitle: subtitle, icon: icon),
        items,
      ],
    );
  }
}
