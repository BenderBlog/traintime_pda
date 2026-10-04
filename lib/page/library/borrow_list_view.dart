// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/borrow_info_card.dart';
import 'package:watermeter/page/library/search_book_constant.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';

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
                text: context.t.library.emptyBorrowList,
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
        height: LocaleSettings.currentLocale == AppLocale.en ? 80 : 50,
        child: Text(
          context.t.library.borrowListInfo(
            borrow: borrowList.length.toString(),
            dued: borrowDuedNum.toString(),
          ),
          maxLines: LocaleSettings.currentLocale == AppLocale.en ? 2 : 1,
        ),
      ),
    );
  }
}
