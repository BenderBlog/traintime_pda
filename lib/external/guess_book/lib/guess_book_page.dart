// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import 'cfbblang_translator.dart';
import 'guess_book_data.dart';

enum _AnswerMode { choice, input }

enum _ClueMode { original, random }

/// 根据表情猜书名的小游戏。
class GuessBookPage extends StatefulWidget {
  const GuessBookPage({
    super.key,
    this.books = guessBookData,
    this.appBarBottom,
    this.showAppBar = true,
  });

  /// 书名到表情的映射。
  final Map<String, String> books;
  final PreferredSizeWidget? appBarBottom;
  final bool showAppBar;

  @override
  State<GuessBookPage> createState() => _GuessBookPageState();
}

class _GuessBookPageState extends State<GuessBookPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _random = Random();
  late final _emojiGenerator = CfbbLangTranslator(random: _random);
  final _scrollController = ScrollController();
  final _answerController = TextEditingController();
  _AnswerMode _mode = _AnswerMode.choice;
  _ClueMode _clueMode = _ClueMode.original;
  String _clue = '';
  bool _usingOriginalFallback = false;
  late List<MapEntry<String, String>> _questions;
  List<String> _options = [];
  int _index = 0;
  String? _selected;
  bool _revealed = false;
  bool _isCorrect = false;

  bool get _answered => _selected != null || _revealed;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(covariant GuessBookPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.books != widget.books) _restart();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _restart() {
    _questions = widget.books.entries.toList()..shuffle(_random);
    _index = 0;
    _selected = null;
    _revealed = false;
    _isCorrect = false;
    _answerController.clear();
    if (_questions.isNotEmpty) _makeOptions();
  }

  void _makeOptions() {
    final answer = _questions[_index].key;
    final answerLength = answer.characters.length;
    final alternatives =
        widget.books.keys
            .where(
              (name) =>
                  name != answer && name.characters.length == answerLength,
            )
            .toList()
          ..shuffle(_random);
    _options = [answer, ...alternatives.take(3)]..shuffle(_random);
    _updateClue();
  }

  void _updateClue() {
    final question = _questions[_index];
    _usingOriginalFallback = false;
    if (_clueMode == _ClueMode.original) {
      _clue = question.value;
      return;
    }
    final generated = _emojiGenerator.translateToEmoji(question.key);
    _usingOriginalFallback = generated.contains('❓');
    _clue = _usingOriginalFallback ? question.value : generated;
  }

  void _select(String name, {bool typed = false}) {
    if (_answered) return;
    final correct = typed
        ? _matchesAnswer(name, _questions[_index].key)
        : name == _questions[_index].key;
    setState(() {
      _selected = name;
      _isCorrect = correct;
    });
  }

  bool _matchesAnswer(String input, String answer) {
    String normalize(String text) => text.toLowerCase().replaceAll(
      RegExp(r'[\s《》〈〉「」『』·・•.,，。!！?？:：;；\-—]'),
      '',
    );

    final normalized = normalize(input);
    if (normalized.isEmpty) return false;
    if (normalized == normalize(answer)) return true;
    // The source includes an English subtitle after the Chinese title.
    final latinStart = RegExp(r'[a-zA-Z]').firstMatch(answer)?.start;
    return latinStart != null &&
        latinStart > 0 &&
        RegExp(r'[\u3400-\u9fff]').hasMatch(answer.substring(0, latinStart)) &&
        normalized == normalize(answer.substring(0, latinStart));
  }

  void _submitAnswer() {
    final value = _answerController.text.trim();
    if (value.isEmpty || _answered) return;
    FocusScope.of(context).unfocus();
    _select(value, typed: true);
  }

  void _next() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() {
      if (_index + 1 == _questions.length) {
        final previous = _questions[_index].key;
        _questions.shuffle(_random);
        if (_questions.length > 1 && _questions.first.key == previous) {
          final other = 1 + _random.nextInt(_questions.length - 1);
          final first = _questions.first;
          _questions[0] = _questions[other];
          _questions[other] = first;
        }
        _index = 0;
      } else {
        _index++;
      }
      _selected = null;
      _revealed = false;
      _isCorrect = false;
      _answerController.clear();
      _makeOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final strings = context.t.guessBook;
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(strings.title), bottom: widget.appBarBottom)
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _questions.isEmpty
                ? Center(child: Text(strings.empty))
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    children: [
                      SegmentedButton<_ClueMode>(
                        segments: [
                          ButtonSegment(
                            value: _ClueMode.original,
                            label: Text(strings.originalClue),
                          ),
                          ButtonSegment(
                            value: _ClueMode.random,
                            label: Text(strings.randomClue),
                          ),
                        ],
                        selected: {_clueMode},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _clueMode = selection.single;
                            _updateClue();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<_AnswerMode>(
                        segments: [
                          ButtonSegment(
                            value: _AnswerMode.choice,
                            label: Text(strings.choiceMode),
                          ),
                          ButtonSegment(
                            value: _AnswerMode.input,
                            label: Text(strings.inputMode),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (selection) {
                          FocusScope.of(context).unfocus();
                          setState(() => _mode = selection.single);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        strings.question,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _mode == _AnswerMode.choice
                            ? strings.instruction
                            : strings.inputInstruction,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        constraints: const BoxConstraints(minHeight: 160),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _clue,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 40, height: 1.4),
                        ),
                      ),
                      if (_usingOriginalFallback) ...[
                        const SizedBox(height: 8),
                        Text(
                          strings.randomClueFallback,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_mode == _AnswerMode.choice)
                        for (final option in _options) ...[
                          _buildOption(option, theme),
                          const SizedBox(height: 10),
                        ]
                      else ...[
                        TextField(
                          controller: _answerController,
                          enabled: !_answered,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: strings.inputLabel,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submitAnswer(),
                        ),
                        const SizedBox(height: 12),
                        if (!_answered)
                          FilledButton(
                            onPressed: _answerController.text.trim().isEmpty
                                ? null
                                : _submitAnswer,
                            child: Text(strings.submit),
                          ),
                      ],
                      const SizedBox(height: 10),
                      if (_answered) ...[
                        Text(
                          _isCorrect
                              ? strings.correct
                              : strings.answer(answer: _questions[_index].key),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _isCorrect ? colors.primary : colors.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _next,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(strings.next),
                        ),
                      ] else
                        TextButton.icon(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _revealed = true);
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          label: Text(strings.reveal),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String option, ThemeData theme) {
    final answer = _questions[_index].key;
    final colors = theme.colorScheme;
    final isAnswer = _answered && option == answer;
    final isWrong = _selected == option && option != answer;
    return OutlinedButton(
      onPressed: _answered ? null : () => _select(option),
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
