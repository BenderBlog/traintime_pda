// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library Window.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/page/library/borrow_list_window.dart';
import 'package:watermeter/page/library/search_book_window.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

class LibraryWindow extends StatelessWidget {
  const LibraryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("图书馆信息"),
          leading: IconButton(
            icon: Icon(
              Platform.isIOS || Platform.isMacOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
            ),
            onPressed: () => context.pop(),
          ),
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
