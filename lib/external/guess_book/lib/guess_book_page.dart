// Copyright 2026 Traintime PDA Authors, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

import 'component/guess_book_view.dart';
import 'state/guess_book_state.dart';
import 'model/guess_book_data.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GuessBookState(
      books: widget.books,
      child: GuessBookView(
        showAppBar: widget.showAppBar,
        appBarBottom: widget.appBarBottom,
      ),
    );
  }
}
