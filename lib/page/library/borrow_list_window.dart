// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Borrow list, shows the user's borrowlist.

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as borrow_info;
import 'package:watermeter/page/library/borrow_info_card.dart';

class BorrowListWindow extends StatelessWidget {
  const BorrowListWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget child() {
        switch (borrow_info.state.value) {
          case SessionState.fetched:
            return const BorrowListDetail();
          case SessionState.fetching:
            return borrow_info.borrowList.isEmpty
                ? const CircularProgressIndicator().center()
                : const BorrowListDetail();
          case SessionState.error:
          case SessionState.none:
            return ReloadWidget(
              function: borrow_info.refreshBorrowList,
            ).center();
        }
      }

      return RefreshIndicator(
        onRefresh: borrow_info.refreshBorrowList,
        child: child(),
      );
    });
  }
}

class BorrowListDetail extends StatelessWidget {
  const BorrowListDetail({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> borrowList = List<Widget>.generate(
      borrow_info.borrowList.length,
      (index) => BorrowInfoCard(toUse: borrow_info.borrowList[index]),
    );

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (borrow_info.borrowList.isNotEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) => AlignedGridView.count(
                shrinkWrap: true,
                itemCount: borrowList.length,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                crossAxisCount: constraints.maxWidth ~/ 360,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                itemBuilder: (context, index) => borrowList[index],
              ),
            );
          } else {
            return EmptyListView(
              type: EmptyListViewType.reading,
              text: FlutterI18n.translate(context, "library.empty_borrow_list"),
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: prefs.getString(Preference.localization.key) == "en_US"
            ? 80
            : 50,
        child: I18nText(
          "library.borrow_list_info",
          translationParams: {
            "borrow": borrow_info.borrowList.length.toString(),
            "dued": borrow_info.dued.toString(),
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
