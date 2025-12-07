// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
// import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as search_book;
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_detail_card.dart';
import 'package:watermeter/page/library/book_info_card.dart';

enum SearchField { keyWord, title, author, isbn, barcode, callNo }

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
        return FlutterI18n.translate(
          context,
          "library.search_field_keyword_option",
        );
      case SearchField.title:
        return FlutterI18n.translate(
          context,
          "library.search_field_title_option",
        );
      case SearchField.isbn:
        return FlutterI18n.translate(
          context,
          "library.search_field_isbn_option",
        );
      case SearchField.author:
        return FlutterI18n.translate(
          context,
          "library.search_field_author_option",
        );
      case SearchField.barcode:
        return FlutterI18n.translate(
          context,
          "library.search_field_barcode_option",
        );
      case SearchField.callNo:
        return FlutterI18n.translate(
          context,
          "library.search_field_callno_option",
        );
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
  late final PagingController<int, BookInfo> _pagingController =
      PagingController<int, BookInfo>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,

        fetchPage: (pageKey) => search_book.LibrarySession().searchBook(
          search,
          pageKey,
          searchField: selectedSearchField.apiValue,
        ),
      );

  String search = '';
  SearchField selectedSearchField = SearchField.keyWord;

  @override
  bool get wantKeepAlive => true;

  late final TextEditingController _textEditingController =
      TextEditingController.fromValue(TextEditingValue(text: search));

  @override
  void dispose() {
    _textEditingController.dispose();
    _pagingController.dispose();
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: FlutterI18n.translate(
                    context,
                    "library.search_here",
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (String textFieldValue) => search = textFieldValue,
                onFieldSubmitted: (value) {
                  _pagingController.refresh();
                },
              ).flexible(flex: 2),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<SearchField>(
                  value: selectedSearchField,
                  items: SearchField.values
                      .map(
                        (SearchField field) => DropdownMenuItem<SearchField>(
                          value: field,
                          child: Text(field.getLabel(context)),
                        ),
                      )
                      .toList(),
                  onChanged: (SearchField? newValue) {
                    if (newValue != null) {
                      selectedSearchField = newValue;
                      _pagingController.refresh();
                    }
                  },
                ),
              ).flexible(),
            ],
          ).padding(vertical: 8).constrained(maxWidth: sheetMaxWidth),
          PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) => LayoutBuilder(
              builder: (context, constraints) =>
                  PagedMasonryGridView<int, BookInfo>.count(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    crossAxisCount: constraints.maxWidth ~/ 360,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    builderDelegate: PagedChildBuilderDelegate<BookInfo>(
                      itemBuilder: (context, item, index) =>
                          GestureDetector(
                                child: BookInfoCard(toUse: item),
                                onTap: () => BothSideSheet.show(
                                  context: context,
                                  title: FlutterI18n.translate(
                                    context,
                                    "library.book_detail",
                                  ),
                                  child: BookDetailCard(toUse: item),
                                ),
                              )
                              .padding(horizontal: 12, vertical: 2)
                              .width(double.infinity)
                              .constrained(width: sheetMaxWidth)
                              .center(),
                      firstPageProgressIndicatorBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      firstPageErrorIndicatorBuilder: (context) => ReloadWidget(
                        function: () async => _pagingController.refresh(),
                        errorStatus: _pagingController.error,
                      ),
                      noItemsFoundIndicatorBuilder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search, size: 96.0),
                              const SizedBox(height: 16),
                              Text(
                                FlutterI18n.translate(
                                  context,
                                  "library.no_result",
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      noMoreItemsIndicatorBuilder: (context) =>
                          [
                                Icon(Icons.sentiment_very_satisfied, size: 32),
                                SizedBox(width: 8),
                                Text(
                                  "That's all folks!",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ]
                              .toRow(
                                mainAxisAlignment: MainAxisAlignment.center,
                              )
                              .padding(vertical: 12)
                              .center(),
                    ),
                  ),
            ),
          ).expanded(),
        ],
      ),
    );
  }
}
