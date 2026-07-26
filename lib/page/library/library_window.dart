// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Library Window.
import 'package:flutter/material.dart';
import 'package:watermeter/page/library/borrow_list_window.dart';
import 'package:watermeter/page/library/search_book_window.dart';
import 'package:watermeter/generated/l10n.dart';

class LibraryWindow extends StatelessWidget {
  const LibraryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context)!.libraryTitle),
          bottom: TabBar(
            tabs: [
              Tab(
                text: I18n.of(context)!.libraryBorrowStateTitle,
              ),
              Tab(
                text: I18n.of(context)!.librarySearchBookTitle,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [BorrowListWindow(), SearchBookWindow()],
        ),
      ),
    );
  }
}
