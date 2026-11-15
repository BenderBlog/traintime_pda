// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/external/guess_book/lib/state/guess_book_controller.dart';

/// Owns the game state and makes it available to descendants.
class GuessBookState extends StatefulWidget {
  const GuessBookState({super.key, required this.books, required this.child});

  final Map<String, String> books;
  final Widget child;

  static GuessBookController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_GuessBookScope>();
    assert(scope != null, 'GuessBookState not found');
    return scope!.notifier!;
  }

  @override
  State<GuessBookState> createState() => _GuessBookStateState();
}

class _GuessBookStateState extends State<GuessBookState> {
  late final GuessBookController controller = GuessBookController(widget.books);

  @override
  void didUpdateWidget(covariant GuessBookState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.books != widget.books) controller.restart(widget.books);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _GuessBookScope(notifier: controller, child: widget.child);
}

class _GuessBookScope extends InheritedNotifier<GuessBookController> {
  const _GuessBookScope({required super.notifier, required super.child});
}
