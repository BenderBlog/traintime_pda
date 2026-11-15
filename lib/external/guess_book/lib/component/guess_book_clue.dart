// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../model/guess_book_mode.dart';
import '../state/guess_book_state.dart';

class GuessBookClue extends StatelessWidget {
  const GuessBookClue({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GuessBookState.of(context);
    final theme = Theme.of(context);
    final strings = context.t.guessBook;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.question, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          state.mode == AnswerMode.choice
              ? strings.instruction
              : strings.inputInstruction,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            state.clue,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 40, height: 1.4),
          ),
        ),
        if (state.usingOriginalFallback) ...[
          const SizedBox(height: 8),
          Text(strings.randomClueFallback, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}
