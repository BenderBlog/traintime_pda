// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../model/guess_book_mode.dart';
import '../state/guess_book_state.dart';

class GuessBookAnswer extends StatelessWidget {
  const GuessBookAnswer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GuessBookState.of(context);
    final strings = context.t.guessBook;
    if (state.mode == AnswerMode.choice) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in state.options) ...[
            _GuessBookOption(option: option),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    void submit() {
      if (!state.canSubmit) return;
      FocusScope.of(context).unfocus();
      state.submitAnswer();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: state.answerController,
          enabled: !state.answered,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: strings.inputLabel,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => submit(),
        ),
        const SizedBox(height: 12),
        if (!state.answered)
          FilledButton(
            onPressed: state.canSubmit ? submit : null,
            child: Text(strings.submit),
          ),
      ],
    );
  }
}

class _GuessBookOption extends StatelessWidget {
  const _GuessBookOption({required this.option});

  final String option;

  @override
  Widget build(BuildContext context) {
    final state = GuessBookState.of(context);
    final colors = Theme.of(context).colorScheme;
    final isAnswer = state.answered && option == state.answer;
    final isWrong = state.selected == option && option != state.answer;
    return OutlinedButton(
      onPressed: state.answered ? null : () => state.select(option),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        foregroundColor: isWrong ? colors.error : colors.onSurface,
        disabledForegroundColor: isAnswer
            ? colors.onPrimaryContainer
            : isWrong
            ? colors.error
            : colors.onSurfaceVariant,
        backgroundColor: isAnswer ? colors.primaryContainer : null,
        side: BorderSide(color: isWrong ? colors.error : colors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(option)),
          if (isAnswer) const Icon(Icons.check_circle_outline),
          if (isWrong) const Icon(Icons.cancel_outlined),
        ],
      ),
    );
  }
}
