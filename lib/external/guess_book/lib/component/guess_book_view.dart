// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../state/guess_book_state.dart';
import 'guess_book_answer.dart';
import 'guess_book_clue.dart';
import 'guess_book_modes.dart';
import 'guess_book_result.dart';

class GuessBookView extends StatelessWidget {
  const GuessBookView({super.key, required this.showAppBar, this.appBarBottom});

  final bool showAppBar;
  final PreferredSizeWidget? appBarBottom;

  @override
  Widget build(BuildContext context) {
    final state = GuessBookState.of(context);
    final strings = context.t.guessBook;
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: Text(strings.title), bottom: appBarBottom)
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: state.isEmpty
                ? Center(child: Text(strings.empty))
                : ListView(
                    controller: state.scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    children: const [
                      GuessBookModes(),
                      SizedBox(height: 24),
                      GuessBookClue(),
                      SizedBox(height: 24),
                      GuessBookAnswer(),
                      SizedBox(height: 10),
                      GuessBookResult(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
