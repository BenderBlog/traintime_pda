// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/borrow_info_card.dart';
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              if (borrowList.isEmpty)
                EmptyListView(
                  type: EmptyListViewType.reading,
                  text: FlutterI18n.translate(
                    context,
                    "library.empty_borrow_list",
                  ),
                ),

              AlignedGridView.count(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: borrowList.length,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                crossAxisCount: constraints.maxWidth ~/ 360,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                itemBuilder: (context, index) =>
                    BorrowInfoCard(toUse: borrowList[index]),
              ),
            ],
          );
        },
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
