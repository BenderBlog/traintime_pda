// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

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
      title: const Text('选择学期'),
      children: List.generate(
        chooseList.length,
        (index) => SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop<int>(index),
          child: ListTile(title: Text(chooseList[index])),
        ),
      ),
    );
  }
}
