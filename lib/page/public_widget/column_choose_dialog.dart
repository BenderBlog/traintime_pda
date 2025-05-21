// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// ColumnChooseDialog is a dialog with a [chooseList] to select, return the index in the [chooseList].
class ColumnChooseDialog extends StatelessWidget {
  final List<String> chooseList;

  const ColumnChooseDialog({
    super.key,
    required this.chooseList,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(FlutterI18n.translate(
        context,
        "choose_semester",
      )),
      children: List.generate(
        chooseList.length,
        (index) => SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop<int>(index),
          child: ListTile(
            title: Text(FlutterI18n.translate(
              context,
              chooseList[index],
            )),
          ),
        ),
      ),
    );
  }
}
