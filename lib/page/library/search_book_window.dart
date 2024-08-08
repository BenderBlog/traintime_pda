// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:both_side_sheet/both_side_sheet.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as search_book;
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_detail_card.dart';
import 'package:watermeter/page/library/book_info_card.dart';

class SearchBookWindow extends StatefulWidget {
  const SearchBookWindow({super.key});

  @override
  State<SearchBookWindow> createState() => _SearchBookWindowState();
}

class _SearchBookWindowState extends State<SearchBookWindow>
    with AutomaticKeepAliveClientMixin {
  var searchList = <BookInfo>[].obs;
  var search = "".obs;
  int page = 1;
  bool noMore = false;
  var isSearching = false.obs;

  @override
  bool get wantKeepAlive => true;

  late EasyRefreshController _controller;
  late TextEditingController text;

  @override
  void initState() {
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    text = TextEditingController.fromValue(
      TextEditingValue(text: search.value),
    );
    super.initState();
  }

  Future<void> searchBook() async {
    if (!noMore) {
      isSearching.value = true;
      List<BookInfo> get = await search_book.LibrarySession().searchBook(
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: TextFormField(
            controller: text,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "在此搜索",
              isDense: false,
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onChanged: (String text) => search.value = text,
            onFieldSubmitted: (value) => setState(() {
              searchList.clear();
              page = 1;
              noMore = false;
              searchBook();
            }),
          ),
        ).padding(
          vertical: 10,
          horizontal: 8,
        ),
        EasyRefresh(
          footer: ClassicFooter(
            dragText: '上拉请求更多'.tr,
            readyText: '正在加载......'.tr,
            processingText: '正在加载......'.tr,
            processedText: '请求成功'.tr,
            noMoreText: '数据没有更多'.tr,
            failedText: '数据获取失败更多'.tr,
            infiniteOffset: null,
          ),
          onLoad: () async {
            await searchBook();
          },
          child: Obx(() {
            if (searchList.isNotEmpty) {
              List<Widget> bookList = List<Widget>.generate(
                searchList.length,
                (index) => GestureDetector(
                  child: BookInfoCard(toUse: searchList[index]),
                  onTap: () => BothSideSheet.show(
                    context: context,
                    title: "书籍详细信息",
                    child: BookDetailCard(
                      toUse: searchList[index],
                    ),
                  ),
                ),
              );
              return LayoutBuilder(
                builder: (context, constraints) => AlignedGridView.count(
                  shrinkWrap: true,
                  itemCount: bookList.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  crossAxisCount: constraints.maxWidth ~/ 360,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) => bookList[index],
                ),
              ).safeArea();
            } else if (isSearching.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (search.value.isNotEmpty) {
              return const Center(child: Text("没有结果"));
            } else {
              return const Center(
                child: Text("请在上面的搜索框中搜索"),
              );
            }
          }),
        ).expanded(),
      ],
    ));
  }
}
