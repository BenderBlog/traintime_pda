// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/borrow_info_card.dart';
import 'package:watermeter/page/library/search_book_constant.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/repository/preference.dart';

class BorrowListView extends StatelessWidget {
  final List<BorrowData> borrowList;
  int get borrowDuedNum =>
      borrowList.where((element) => element.lendDay < 0).length;
  const BorrowListView({super.key, required this.borrowList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => (borrowList.isEmpty)
            ? EmptyListView(
                type: EmptyListViewType.reading,
                text: FlutterI18n.translate(
                  context,
                  "library.empty_borrow_list",
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) => AlignedGridView.count(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: borrowList.length,
                  padding: const EdgeInsets.all(4),
                  crossAxisCount: max(
                    1,
                    constraints.maxWidth ~/ resultCardMaxWidth,
                  ),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) => LayoutBuilder(
                    builder: (context, constraints) => BorrowInfoCard(
                      toUse: borrowList[index],
                      constraints: constraints,
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: prefs.getString(Preference.localization.key) == "en_US"
            ? 80
            : 50,
        child: I18nText(
          "library.borrow_list_info",
          translationParams: {
            "borrow": borrowList.length.toString(),
            "dued": borrowDuedNum.toString(),
          },
          child: Text(
            "",
            maxLines: prefs.getString(Preference.localization.key) == "en_US"
                ? 2
                : 1,
          ),
        ),
      ),
    );
  }
}
