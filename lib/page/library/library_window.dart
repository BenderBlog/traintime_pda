// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// Library Window.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/page/library/borrow_list_window.dart';
import 'package:watermeter/page/library/query_book_window.dart';

class LibraryWindow extends StatelessWidget {
  final LibraryController c = Get.put(LibraryController());
  LibraryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("图书馆信息"),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    title: Text("图书馆功能"),
                    content: Text(
                      "支持查书和查看当前借阅状况。\n"
                      "扫码借书和扫码转借书将不会支持，因为我是非官方软件，怕写完有风险。\n"
                      "如果各位真有需求，我将会考虑实现。",
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.info),
            )
          ],
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
            QueryBookWindow(),
          ],
        ),
      ),
    );
  }
}
