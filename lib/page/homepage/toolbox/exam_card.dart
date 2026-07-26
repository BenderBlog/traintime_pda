// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/generated/l10n.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onPressed: () => context.pushReplacementNamed(Routes.exam),
      icon: MingCuteIcons.mgc_calendar_line,
      name: I18n.of(context)!.homepageToolboxExam,
    );
  }
}
