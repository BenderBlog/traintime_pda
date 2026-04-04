// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Borrow list, shows the user's borrowlist.

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/page/library/borrow_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

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

    return RefreshIndicator(
      onRefresh: LibraryController.i.reloadBorrowList,
      child: LibraryController.i.libraryBorrowSignal
          .watch(context)
          .map(
            data: (list) => BorrowListView(borrowList: list),
            loading: () => const CircularProgressIndicator().center(),
            refreshing: () => const CircularProgressIndicator().center(),
            reloading: () => const CircularProgressIndicator().center(),
            error: (err, stack) => ReloadWidget(
              errorStatus: err,
              stackTrace: stack,
              function: LibraryController.i.reloadBorrowList,
            ).center(),
          ),
    );
  }
}
