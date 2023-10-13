// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

/// ColumnChooseDialog is a dialog with a [chooseList] to select, return the index in the [chooseList].
class ColumnChooseDialog extends StatefulWidget {
  final List<String> chooseList;

  const ColumnChooseDialog({
    super.key,
    required this.chooseList,
  });

  @override
  State<ColumnChooseDialog> createState() => _ColumnChooseDialogState();
}

class _ColumnChooseDialogState extends State<ColumnChooseDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('选择学期'),
      children: List.generate(
        widget.chooseList.length,
        (index) => SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop<int>(
            index,
          ),
          child: ListTile(
            title: Text(
              widget.chooseList[index],
            ),
          ),
        ),
      ),
    );
  }
}
