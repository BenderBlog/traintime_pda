// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../model/guess_book_mode.dart';
import '../tools/cfbblang_translator.dart';

/// Game data, actions and controllers for the book quiz.
class GuessBookController extends ChangeNotifier {
  final _random = Random();
  final scrollController = ScrollController();
  final answerController = TextEditingController();
  late final emojiGenerator = CfbbLangTranslator(random: _random);

  GuessBookController(Map<String, String> books) {
    answerController.addListener(_answerChanged);
    restart(books);
  }

  late Map<String, String> _books;
  late List<MapEntry<String, String>> _questions;
  int _index = 0;
  bool get isEmpty => _questions.isEmpty;
  String get answer => _questions[_index].key;

  AnswerMode _mode = AnswerMode.choice;
  AnswerMode get mode => _mode;
  void setAnswerMode(AnswerMode mode) {
    _mode = mode;
    notifyListeners();
  }

  ClueMode _clueMode = ClueMode.original;
  ClueMode get clueMode => _clueMode;
  void setClueMode(ClueMode mode) {
    _clueMode = mode;
    if (!isEmpty) _updateClue();
    notifyListeners();
  }

  String _clue = '';
  String get clue => _clue;

  bool _usingOriginalFallback = false;
  bool get usingOriginalFallback => _usingOriginalFallback;

  List<String> _options = [];
  List<String> get options => List.unmodifiable(_options);

  String? _selected;
  String? get selected => _selected;

  bool _revealed = false;
  bool get answered => _selected != null || _revealed;

  bool _isCorrect = false;
  bool get isCorrect => _isCorrect;

  bool get canSubmit => answerController.text.trim().isNotEmpty && !answered;

  void _answerChanged() => notifyListeners();

  void restart(Map<String, String> books) {
    _books = books;
    _questions = books.entries.toList()..shuffle(_random);
    _index = 0;
    _selected = null;
    _revealed = false;
    _isCorrect = false;
    _options = [];
    _clue = '';
    _usingOriginalFallback = false;
    answerController.clear();
    if (_questions.isNotEmpty) _makeOptions();
    notifyListeners();
  }

  void _makeOptions() {
    final answerLength = answer.characters.length;
    final alternatives =
        _books.keys
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
    if (_clueMode == ClueMode.original) {
      _clue = question.value;
      return;
    }
    final generated = emojiGenerator.translateToEmoji(question.key);
    _usingOriginalFallback = generated.contains('❓');
    _clue = _usingOriginalFallback ? question.value : generated;
  }

  void select(String name, {bool typed = false}) {
    if (answered || isEmpty) return;
    _isCorrect = typed ? _matchesAnswer(name, answer) : name == answer;
    _selected = name;
    notifyListeners();
  }

  bool _matchesAnswer(String input, String answer) {
    String normalize(String text) => text.toLowerCase().replaceAll(
      RegExp(r'[\s《》〈〉「」『』·・•.,，。!！?？:：;；\-—]'),
      '',
    );

    final normalized = normalize(input);
    if (normalized.isEmpty) return false;
    if (normalized == normalize(answer)) return true;
    final latinStart = RegExp(r'[a-zA-Z]').firstMatch(answer)?.start;
    return latinStart != null &&
        latinStart > 0 &&
        RegExp(r'[\u3400-\u9fff]').hasMatch(answer.substring(0, latinStart)) &&
        normalized == normalize(answer.substring(0, latinStart));
  }

  void submitAnswer() {
    if (!canSubmit) return;
    select(answerController.text.trim(), typed: true);
  }

  void reveal() {
    if (answered || isEmpty) return;
    _revealed = true;
    notifyListeners();
  }

  void next() {
    if (isEmpty) return;
    if (scrollController.hasClients) scrollController.jumpTo(0);
    if (_index + 1 == _questions.length) {
      final previous = answer;
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
    answerController.clear();
    _makeOptions();
    notifyListeners();
  }

  @override
  void dispose() {
    answerController.removeListener(_answerChanged);
    answerController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
