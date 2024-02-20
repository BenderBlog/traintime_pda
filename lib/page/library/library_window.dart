// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library Window.

import 'package:flutter/material.dart';
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
          title: const Text("图书馆信息"),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "借书状态",
              ),
              Tab(
                text: "查询藏书",
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
