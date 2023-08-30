// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Score Watermark when showing score detail.

import 'package:flutter/material.dart';
import 'dart:math';

class Watermark extends StatelessWidget {
  final int rowCount;
  final int columnCount;
  final String text;
  final TextStyle textStyle;

  const Watermark({
    Key? key,
    required this.rowCount,
    required this.columnCount,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListView(
        children: _createColumnWidgets(),
      ),
    );
  }

  List<Widget> _createColumnWidgets() => List<Widget>.generate(
        columnCount,
        (index) => Transform.rotate(
          angle: -pi / 20,
          child: Expanded(
            child: Row(
              children: _createRowWidgets(),
            ),
          ),
        ),
      );

  List<Widget> _createRowWidgets() => List<Widget>.generate(
        rowCount,
        (index) => Expanded(
          child: Center(
            child: Text(text, style: textStyle),
          ),
        ),
      );
}
