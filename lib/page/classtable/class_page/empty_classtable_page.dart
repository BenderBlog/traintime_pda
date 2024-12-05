// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';

class EmptyClasstablePage extends StatelessWidget {
  const EmptyClasstablePage({super.key});

  @override
  Widget build(BuildContext context) => EmptyListView(
        type: Type.reading,
        text: FlutterI18n.translate(
          context,
          "classtable.empty_class_message",
        ),
      );
}
