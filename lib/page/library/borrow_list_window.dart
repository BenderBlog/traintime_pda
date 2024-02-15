// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Borrow list, shows the user's borrowlist.

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/network_session.dart';
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
            );
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
      body: Builder(builder: (context) {
        if (borrow_info.borrowList.isNotEmpty) {
          return AlignedGridView.count(
            shrinkWrap: true,
            itemCount: borrowList.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            crossAxisCount: MediaQuery.sizeOf(context).width ~/ 360,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemBuilder: (context, index) => borrowList[index],
          );
        } else {
          return const Text("目前没有查询到在借图书").center().expanded();
        }
      }),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "仍在借 ${borrow_info.notDued} 本\n" "已过期 ${borrow_info.dued} 本",
            ),
          ],
        ),
      ),
    );
  }
}
