// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as search_book;
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_detail_card.dart';
import 'package:watermeter/page/library/book_info_card.dart';

enum SearchField {
  keyWord,
  title,
  author,
  isbn,
  barcode,
  callNo,
}

extension SearchFieldExtension on SearchField {
  String get apiValue {
    switch (this) {
      case SearchField.keyWord:
        return "keyWord";
      case SearchField.title:
        return "title";
      case SearchField.isbn:
        return "isbn";
      case SearchField.author:
        return "author";
      case SearchField.barcode:
        return "barcode";
      case SearchField.callNo:
        return "callNo";
    }
  }

  String getLabel(BuildContext context) {
    switch (this) {
      case SearchField.keyWord:
        return FlutterI18n.translate(context, "library.search_field_keyword_option");
      case SearchField.title:
        return FlutterI18n.translate(context, "library.search_field_title_option");
      case SearchField.isbn:
        return FlutterI18n.translate(context, "library.search_field_isbn_option");
      case SearchField.author:
        return FlutterI18n.translate(context, "library.search_field_author_option");
      case SearchField.barcode:
        return FlutterI18n.translate(context, "library.search_field_barcode_option");
      case SearchField.callNo:
        return FlutterI18n.translate(context, "library.search_field_callno_option");
    }
  }
}

class SearchBookWindow extends StatefulWidget {
  const SearchBookWindow({super.key});

  @override
  State<SearchBookWindow> createState() => _SearchBookWindowState();
}

class _SearchBookWindowState extends State<SearchBookWindow>
    with AutomaticKeepAliveClientMixin {
  var searchList = <BookInfo>[].obs;
  var search = "".obs;
  var selectedSearchField = SearchField.keyWord.obs;
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
        searchField: selectedSearchField.value.apiValue,
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
          // Search field selector and input
          Row(
            children: [
              Obx(() => DropdownButtonFormField<SearchField>(
                value: selectedSearchField.value,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    "library.search_field_title",
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                items: SearchField.values
                    .map((SearchField field) => DropdownMenuItem<SearchField>(
                      value: field,
                      child: Text(field.getLabel(context)),
                    ))
                    .toList(),
                onChanged: (SearchField? newValue) {
                  if (newValue != null) {
                    selectedSearchField.value = newValue;
                  }
                },
              )).padding(horizontal: 8, vertical: 8).expanded(),
              const SizedBox(width: 8),
            ],
          ).padding(horizontal: 8),
          TextFormField(
                controller: text,
                decoration: InputDecoration(
                  hintText: FlutterI18n.translate(
                    context,
                    "library.search_here",
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (String text) => search.value = text,
                onFieldSubmitted: (value) => setState(() {
                  searchList.clear();
                  page = 1;
                  noMore = false;
                  searchBook();
                }),
              )
              .padding(horizontal: 16, vertical: 12)
              .constrained(maxWidth: sheetMaxWidth),
          EasyRefresh(
            footer: ClassicFooter(
              dragText: FlutterI18n.translate(context, "drag_text"),
              readyText: FlutterI18n.translate(context, "ready_text"),
              processingText: FlutterI18n.translate(context, "processing_text"),
              processedText: FlutterI18n.translate(context, "processed_text"),
              noMoreText: FlutterI18n.translate(context, "no_more_text"),
              failedText: FlutterI18n.translate(context, "failed_text"),
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
                      title: FlutterI18n.translate(
                        context,
                        "library.book_detail",
                      ),
                      child: BookDetailCard(toUse: searchList[index]),
                    ),
                  ),
                );
                return ListView.builder(
                  itemCount: bookList.length,
                  itemBuilder: (context, index) => bookList[index]
                      .padding(horizontal: 12, vertical: 2)
                      .width(double.infinity)
                      .constrained(width: sheetMaxWidth)
                      .center(),
                );
              } else if (isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (search.value.isNotEmpty) {
                return EmptyListView(
                  type: EmptyListViewType.reading,
                  text: FlutterI18n.translate(context, "library.no_result"),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, size: 96),
                    const Divider(color: Colors.transparent),
                    Text(
                      FlutterI18n.translate(context, "library.please_search"),
                    ),
                  ],
                );
              }
            }),
          ).expanded(),
        ],
      ),
    );
  }
}
