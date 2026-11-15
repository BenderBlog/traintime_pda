// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../model/guess_book_mode.dart';
import '../state/guess_book_state.dart';

class GuessBookModes extends StatelessWidget {
  const GuessBookModes({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GuessBookState.of(context);
    final strings = context.t.guessBook;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ClueMode>(
          segments: [
            ButtonSegment(
              value: ClueMode.original,
              label: Text(strings.originalClue),
            ),
            ButtonSegment(
              value: ClueMode.random,
              label: Text(strings.randomClue),
            ),
          ],
          selected: {state.clueMode},
          onSelectionChanged: (selection) =>
              state.setClueMode(selection.single),
        ),
        const SizedBox(height: 12),
        SegmentedButton<AnswerMode>(
          segments: [
            ButtonSegment(
              value: AnswerMode.choice,
              label: Text(strings.choiceMode),
            ),
            ButtonSegment(
              value: AnswerMode.input,
              label: Text(strings.inputMode),
            ),
          ],
          selected: {state.mode},
          onSelectionChanged: (selection) {
            FocusScope.of(context).unfocus();
            state.setAnswerMode(selection.single);
          },
        ),
      ],
    );
  }
}
