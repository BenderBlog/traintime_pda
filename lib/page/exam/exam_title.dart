import 'package:flutter/material.dart';

class ExamTitle extends StatelessWidget {
  final String title;

  const ExamTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textScaleFactor: 1.1,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
