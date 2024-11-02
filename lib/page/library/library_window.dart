// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library Window.
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/library/borrow_list_window.dart';
import 'package:watermeter/page/library/search_book_window.dart';

class LibraryWindow extends StatelessWidget {
  const LibraryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "library.title")),
          bottom: TabBar(
            tabs: [
              Tab(
                text: FlutterI18n.translate(
                  context,
                  "library.borrow_state_title",
                ),
              ),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  "library.search_book_title",
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BorrowListWindow(),
            SearchBookWindow(),
          ],
        ),
      ),
    );
  }
}
