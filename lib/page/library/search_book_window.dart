// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/library/search_book_constant.dart';
import 'package:watermeter/page/library/search_fields.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
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
  late final PagingController<int, BookInfo> _pagingController =
      PagingController<int, BookInfo>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,

        fetchPage: _fetchPage,
      );

  BookSearchQuery? _searchQuery;
  bool _hasSearched = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<BookInfo>> _fetchPage(int pageKey) {
    final query = _searchQuery;
    if (query == null) return Future.value(const []);

    final session = search_book.LibrarySession();
    if (query.isAdvanced) {
      return session.advancedSearchBook(
        query.keyword,
        pageKey,
        searchField: query.searchField,
        matchMode: query.matchMode,
        docCode: query.documentType,
        resourceType: query.resourceType,
        campusId: query.campusId,
        locationId: query.locationId,
        countryCode: query.countryCode,
        langCode: query.languageCode,
        onlyOnShelf: query.onlyOnShelf,
        publishBegin: query.publishBegin,
        publishEnd: query.publishEnd,
      );
    }
    return session.searchBook(
      query.keyword,
      pageKey,
      searchField: query.searchField,
    );
  }

  void _submitSearch(BookSearchQuery query) {
    setState(() {
      _searchQuery = query;
      _hasSearched = true;
    });
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          SearchFields(onSearch: _submitSearch),
          if (_hasSearched) _buildResultList().expanded(),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => LayoutBuilder(
        builder: (context, constraints) {
          return PagedMasonryGridView<int, BookInfo>.count(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.all(4),
            crossAxisCount: max(1, constraints.maxWidth ~/ resultCardMaxWidth),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            builderDelegate: PagedChildBuilderDelegate<BookInfo>(
              itemBuilder: (context, item, index) => GestureDetector(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      BookInfoCard(toUse: item, constraints: constraints),
                ),
                onTap: () => _openBookDetail(item),
              ),
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
                        FlutterI18n.translate(context, "library.no_result"),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // TODO: 致 Codex
              // 1. 文字需要国际化
              // 2. 文字大小和图标大小需要修改
              // 3. 图标是不是可以换一个
              noMoreItemsIndicatorBuilder: (context) =>
                  [
                        Icon(Icons.sentiment_very_satisfied, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "没有更多数据了",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ]
                      .toRow(mainAxisAlignment: MainAxisAlignment.center)
                      .padding(vertical: 12)
                      .center()
                      .card(elevation: 0),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openBookDetail(BookInfo item) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await BothSideSheet.show(
      context: context,
      title: FlutterI18n.translate(context, "library.book_detail"),
      child: BookDetailCard(toUse: item),
    );
  }
}
