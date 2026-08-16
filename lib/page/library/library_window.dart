// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Library Window.
import 'package:flutter/material.dart';
import 'package:watermeter/page/library/borrow_list_window.dart';
import 'package:watermeter/page/library/search_book_window.dart';
import 'package:watermeter/generated/translations.g.dart';

class LibraryWindow extends StatelessWidget {
  const LibraryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.library.title),
          bottom: TabBar(
            tabs: [
              Tab(
                text: context.t.library.borrowStateTitle,
              ),
              Tab(
                text: context.t.library.searchBookTitle,
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
