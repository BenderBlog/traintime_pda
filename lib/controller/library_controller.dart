// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

import 'dart:developer' as developer;

// TODO: Remove this controller.

class LibraryController extends GetxController {
  var searchList = <BookInfo>[].obs;
  var search = "".obs;
  int page = 1;
  bool noMore = false;
  var isSearching = false.obs;

  void updateController() async {
    developer.log(
      "Updating...",
      name: "LibraryController",
    );
    await LibrarySession().initSession();
  }

  @override
  void onInit() {
    /// Monitor its change.
    ever(search, (value) {
      searchList.clear();
      page = 1;
      noMore = false;
    });
    super.onInit();
  }

  Future<void> searchBook() async {
    if (!noMore) {
      isSearching.value = true;
      List<BookInfo> get = await LibrarySession().searchBook(
        search.value,
        page,
      );
      if (get.isEmpty) {
        noMore = true;
      } else {
        searchList.addAll(get);
        page++;
      }
      isSearching.value = false;
    }
  }
}
