// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/repository/preference.dart';

class EmptyClasstablePage extends StatelessWidget {
  const EmptyClasstablePage({super.key});

  @override
  Widget build(BuildContext context) => EmptyListView(
        type: EmptyListViewType.defaultimg,
        text: FlutterI18n.translate(context, "classtable.empty_class_message",
            translationParams: {
              "semester_code": getString(Preference.currentSemester)
            }),
      );
}
