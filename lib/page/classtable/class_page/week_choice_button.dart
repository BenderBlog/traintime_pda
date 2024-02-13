// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// This is the button of the toprow
class WeekChoiceButton extends StatefulWidget {
  final int index;
  const WeekChoiceButton({
    super.key,
    required this.index,
  });

  @override
  State<WeekChoiceButton> createState() => _WeekChoiceButtonState();
}

class _WeekChoiceButtonState extends State<WeekChoiceButton> {
  late ClassTableWidgetState classTableState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!.controllers;
  }

  /// [buttonInformaion] shows the botton's [index] and the overview.
  ///
  /// A [index] is required to render the botton for the week.
  Widget buttonInformaion({required int index}) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AutoSizeText(
            "第${index + 1}周",
            style: TextStyle(
              fontWeight: index == classTableState.currentWeek
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            maxLines: 1,
            group: AutoSizeGroup(),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return buttonInformaion(index: widget.index)
        .padding(all: 6)
        .constrained(width: weekButtonWidth);
  }
}
