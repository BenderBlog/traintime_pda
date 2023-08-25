// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class LibraryController extends GetxController {
  RxBool isGet = false.obs;
  RxBool error = false.obs;
  List<BorrowData> borrowList = [];

  var searchList = <BookInfo>[].obs;
  var search = "".obs;
  int page = 1;
  bool noMore = false;
  var isSearching = false.obs;

  int get dued => borrowList.where((element) => element.lendDay < 0).length;
  int get notDued => borrowList.where((element) => element.lendDay >= 0).length;

  @override
  void onReady() async {
    super.onReady();
    isGet.value = false;
    await LibrarySession().initSession();
    await getBorrowList();
  }

  Future<void> getBorrowList() async {
    try {
      if (error.value) {
        error.value = false;
        await LibrarySession().initSession();
      }
      borrowList.addAll(await LibrarySession().getBorrowList());
      isGet.value = true;
      error.value = false;
      update();
    } catch (e) {
      error.value = true;
    }
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
      List<BookInfo> get =
          await LibrarySession().searchBook(search.value, page);
      if (get.isEmpty) {
        noMore = true;
      } else {
        searchList.addAll(get);
        page++;
      }
      isSearching.value = false;
    }
  }

  Future<List<BookLocation>> getLocation(BookInfo toUse) =>
      LibrarySession().getBookLocation(toUse);
}
