// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/generated/translations.g.dart';

class LibraryCard extends StatelessWidget {
  const LibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final state = LibraryController.i.libraryBorrowStateSignal.value;
        return MainPageCard(
          onPressed: () async {
            context.pushReplacementNamed(Routes.library);
          },
          isLoad: state.isLoading,
          icon: MingCuteIcons.mgc_book_2_line,
          text:
              context.t.homepage.libraryCard.title,
          infoText: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: [
                state.map(
                  data: (list) => TextSpan(
                    text: context.t.homepage.libraryCard.currentBorrow(count: list.length.toString()),
                  ),
                  loading: () => TextSpan(
                    text: context.t.homepage.libraryCard.fetching,
                  ),
                  refreshing: () => TextSpan(
                    text: context.t.homepage.libraryCard.fetching,
                  ),
                  reloading: () => TextSpan(
                    text: context.t.homepage.libraryCard.fetching,
                  ),
                  error: (_, _) => TextSpan(
                    text: context.t.homepage.libraryCard.errorOccured,
                  ),
                ),
              ],
            ),
          ),
          bottomText: DefaultTextStyle.merge(
            overflow: TextOverflow.ellipsis,
            child: state.map(
              data: (data) {
                int duedNum =
                    data.where((element) => element.lendDay < 0).length;
                if (duedNum == 0) {
                  return Text(
                    context.t.homepage.libraryCard.noReturn,
                  );
                }
                return Text(
                  context.t.homepage.libraryCard.needReturn(dued: duedNum.toString()),
                );
              },
              loading: () => Text(
                context.t.homepage.libraryCard.fetchingInfo,
              ),
              refreshing: () => Text(
                context.t.homepage.libraryCard.fetchingInfo,
              ),
              reloading: () => Text(
                context.t.homepage.libraryCard.fetchingInfo,
              ),
              error: (_, _) => Text(
                context.t.homepage.libraryCard.noInfo,
              ),
            ),
          ),
        );
      },
    );
  }
}
