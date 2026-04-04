// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/library/library_window.dart';

class LibraryCard extends StatelessWidget {
  const LibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final state = LibraryController.i.libraryBorrowSignal.watch(context);
      return MainPageCard(
        onPressed: () async {
          context.pushReplacement(const LibraryWindow());
        },
        isLoad: state.isLoading,
        icon: MingCuteIcons.mgc_book_2_line,
        text: FlutterI18n.translate(context, "homepage.library_card.title"),
        infoText: Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 20),
            children: [
              state.map(
                data: (list) => TextSpan(
                  text: FlutterI18n.translate(
                    context,
                    "homepage.library_card.current_borrow",
                    translationParams: {"count": list.length.toString()},
                  ),
                ),
                loading: () => TextSpan(
                  text: FlutterI18n.translate(
                    context,
                    "homepage.library_card.fetching",
                  ),
                ),
                refreshing: () => TextSpan(
                  text: FlutterI18n.translate(
                    context,
                    "homepage.library_card.fetching",
                  ),
                ),
                reloading: () => TextSpan(
                  text: FlutterI18n.translate(
                    context,
                    "homepage.library_card.fetching",
                  ),
                ),
                error: (_, _) => TextSpan(
                  text: FlutterI18n.translate(
                    context,
                    "homepage.library_card.error_occured",
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomText: DefaultTextStyle.merge(
          overflow: TextOverflow.ellipsis,
          child: state.map(
            data: (data) {
              int duedNum = data.where((element) => element.lendDay < 0).length;
              if (duedNum == 0) {
                return Text(
                  FlutterI18n.translate(
                    context,
                    "homepage.library_card.no_return",
                  ),
                );
              }
              return Text(
                FlutterI18n.translate(
                  context,
                  "homepage.library_card.need_return",
                  translationParams: {"dued": duedNum.toString()},
                ),
              );
            },
            loading: () => Text(
              FlutterI18n.translate(
                context,
                "homepage.library_card.fetching_info",
              ),
            ),
            refreshing: () => Text(
              FlutterI18n.translate(
                context,
                "homepage.library_card.fetching_info",
              ),
            ),
            reloading: () => Text(
              FlutterI18n.translate(
                context,
                "homepage.library_card.fetching_info",
              ),
            ),
            error: (_, _) => Text(
              FlutterI18n.translate(context, "homepage.library_card.no_info"),
            ),
          ),
        ),
      );
    });
  }
}
