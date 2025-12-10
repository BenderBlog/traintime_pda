// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';

class WeekSelector extends StatefulWidget {
  final List<bool> initialWeeks;
  final ValueChanged<List<bool>> onChanged;
  final Color color;

  const WeekSelector({
    super.key,
    required this.initialWeeks,
    required this.onChanged,
    required this.color,
  });

  @override
  State<WeekSelector> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  late List<bool> chosenWeek;

  @override
  void initState() {
    super.initState();
    chosenWeek = List<bool>.from(widget.initialWeeks);
  }

  Widget weekDoc({required int index}) {
    return Text((index + 1).toString())
        .textColor(widget.color)
        .center()
        .decorated(
          color: chosenWeek[index] ? widget.color.withValues(alpha: 0.2) : null,
          borderRadius: const BorderRadius.all(Radius.circular(100.0)),
        )
        .clipOval()
        .gestures(
          onTap: () {
            setState(() => chosenWeek[index] = !chosenWeek[index]);
            widget.onChanged(chosenWeek);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month, color: widget.color, size: 16),
            Text(
              FlutterI18n.translate(
                context,
                "classtable.class_add.input_week_hint",
              ),
            ).textStyle(TextStyle(color: widget.color)).padding(left: 4),
          ],
        ),
        const SizedBox(height: 8),
        GridView.extent(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          maxCrossAxisExtent: 30,
          children: List.generate(
            chosenWeek.length,
            (index) => weekDoc(index: index),
          ),
        ),
      ],
    )
        .padding(all: 12)
        .card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        );
  }
}
