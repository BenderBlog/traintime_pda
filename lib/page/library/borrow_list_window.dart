// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Borrow list, shows the user's borrowlist.

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/page/library/borrow_info_card.dart';

class BorrowListWindow extends StatelessWidget {
  const BorrowListWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryController c = Get.put(LibraryController());

    List<Widget> borrowList = List<Widget>.generate(
      c.borrowList.length,
      (index) => BorrowInfoCard(toUse: c.borrowList[index]),
    );

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            elevation: 0,
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("仍在借"),
                      Text("${c.notDued} 本"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("已过期"),
                      Text("${c.dued} 本"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        if (c.borrowList.isNotEmpty)
          AlignedGridView.count(
            shrinkWrap: true,
            itemCount: borrowList.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            crossAxisCount: MediaQuery.sizeOf(context).width ~/ 360,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemBuilder: (context, index) => borrowList[index],
          )
        else
          const Text("目前没有查询到在借图书").center().expanded(),
      ],
    );
  }
}
