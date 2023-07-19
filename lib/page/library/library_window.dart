/*
Library Window.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
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
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner),
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
        body: TabBarView(
          children: [
            BorrowListWindow(),
            const QueryBookWindow(),
          ],
        ),
      ),
    );
  }
}
