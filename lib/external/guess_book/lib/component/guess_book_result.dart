// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../state/guess_book_state.dart';

class GuessBookResult extends StatelessWidget {
  const GuessBookResult({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GuessBookState.of(context);
    final theme = Theme.of(context);
    final strings = context.t.guessBook;
    if (!state.answered) {
      return TextButton.icon(
        onPressed: () {
          FocusScope.of(context).unfocus();
          state.reveal();
        },
        icon: const Icon(Icons.lightbulb_outline),
        label: Text(strings.reveal),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.isCorrect
              ? strings.correct
              : strings.answer(answer: state.answer),
          style: theme.textTheme.titleMedium?.copyWith(
            color: state.isCorrect
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: state.next,
          icon: const Icon(Icons.arrow_forward),
          label: Text(strings.next),
        ),
      ],
    );
  }
}
