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

class BorrowListWindow extends StatefulWidget {
  const BorrowListWindow({super.key});

  @override
  State<BorrowListWindow> createState() => _BorrowListWindowState();
}

class _BorrowListWindowState extends State<BorrowListWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      Widget child() {
        switch (borrow_info.state.value) {
          case SessionState.fetching:
            return borrow_info.borrowList.isEmpty
                ? const CircularProgressIndicator().center()
                : const BorrowListDetail();
          case SessionState.fetched:
            return const BorrowListDetail();
          case SessionState.error:
          case SessionState.none:
            return ReloadWidget(
              errorStatus: borrow_info.error,
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              EmptyListView(
                type: EmptyListViewType.reading,
                text: FlutterI18n.translate(
                  context,
                  "library.empty_borrow_list",
                ),
              ),

              ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (borrow_info.borrowList.isNotEmpty)
                    AlignedGridView.count(
                      itemCount: borrow_info.borrowList.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      crossAxisCount: constraints.maxWidth ~/ 360,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      itemBuilder: (context, index) =>
                          BorrowInfoCard(toUse: borrow_info.borrowList[index]),
                    ),
                ],
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
