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
import 'package:watermeter/page/library/borrow_info_card.dart';

class LibraryWindow extends StatelessWidget {
  final LibraryController c = Get.put(LibraryController());
  LibraryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("图书馆信息"),
      ),
      body: ListView(
        children: [
          for (var i in c.borrowList) BorrowInfoCard(toUse: i),
        ],
      ),
    );
  }
}
