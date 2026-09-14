// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class ClassTablePreview extends StatelessWidget {
  const ClassTablePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: LayoutBuilder(
        builder: (context, constraint) {
          final previewState = _PreviewClassTableState();
          return ClassTableState(
            constraints: constraint,
            controllers: previewState,
            child: IgnorePointer(
              child: ClassTableView(
                index: previewState.currentWeek,
                constraint: constraint,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewClassTableState extends ClassTableWidgetState {
  @override
  int get offset => 0;
}
