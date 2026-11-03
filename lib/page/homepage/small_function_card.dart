// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';

class SmallFunctionCard extends StatelessWidget {
  final IconData icon;
  final String name;
  // 转场需要等页面真的返回，所以这里保持 FutureOr（上游是 void）。
  final FutureOr<void> Function()? onPressed;
  final bool enableContainerTransform;

  const SmallFunctionCard({
    super.key,
    required this.icon,
    required this.name,
    this.onPressed,
    this.enableContainerTransform = true,
  });

  @override
  Widget build(BuildContext context) {
    return [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]
        .toColumn(mainAxisAlignment: MainAxisAlignment.center)
        .alignment(Alignment.center)
        .withHomeCardStyle(
          context,
          onPressed: onPressed,
          enableContainerTransform: enableContainerTransform,
        );
  }
}
