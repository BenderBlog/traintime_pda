// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';
import 'package:watermeter/page/classtable/classtable_launch_target.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/routing/routes.dart';

Future<void> handleWidgetLaunchUri(BuildContext context, Uri? uri) async {
  final target = ClassTableLaunchTarget.fromUri(uri);
  if (target == null || !context.mounted) return;

  await context.pushReplacementNamed(
    Routes.classTable,
    arguments: target,
  );
}
