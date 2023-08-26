// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class ColumnChooseDialog extends StatefulWidget {
  final List<String> semesterList;

  const ColumnChooseDialog({
    super.key,
    required this.semesterList,
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
        widget.semesterList.length,
        (index) => SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop<int>(
            index,
          ),
          child: ListTile(
            title: Text(
              widget.semesterList[index],
            ),
          ),
        ),
      ),
    );
  }
}
