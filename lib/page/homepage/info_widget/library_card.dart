// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as borrow_info;
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/library/library_window.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class LibraryCard extends StatelessWidget {
  const LibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (offline) {
          showToast(
            context: context,
            msg: FlutterI18n.translate(
              context,
              "homepage.offline_mode",
            ),
          );
        } else {
          context.pushReplacement(const LibraryWindow());
        }
      },
      child: Obx(
        () => MainPageCard(
          isLoad: borrow_info.state.value == SessionState.fetching,
          icon: MingCuteIcons.mgc_book_2_line,
          text: FlutterI18n.translate(
            context,
            "homepage.library_card.title",
          ),
          infoText: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: [
                if (borrow_info.state.value == SessionState.fetched) ...[
                  TextSpan(
                    text: FlutterI18n.translate(
                      context,
                      "homepage.library_card.current_borrow",
                      translationParams: {
                        "count": borrow_info.borrowList.length.toString(),
                      },
                    ),
                  )
                ] else if (borrow_info.state.value == SessionState.error)
                  TextSpan(
                    text: FlutterI18n.translate(
                      context,
                      "homepage.library_card.error_occured",
                    ),
                  )
                else
                  TextSpan(
                    text: FlutterI18n.translate(
                      context,
                      "homepage.library_card.fetching",
                    ),
                  )
              ],
            ),
          ),
          bottomText: Obx(() {
            return DefaultTextStyle.merge(
              overflow: TextOverflow.ellipsis,
              child: Text(
                borrow_info.state.value == SessionState.fetched
                    ? borrow_info.dued == 0
                        ? FlutterI18n.translate(
                            context,
                            "homepage.library_card.no_return",
                          )
                        : FlutterI18n.translate(
                            context,
                            "homepage.library_card.need_return",
                            translationParams: {
                              "dued": borrow_info.dued.toString()
                            },
                          )
                    : borrow_info.state.value == SessionState.error
                        ? FlutterI18n.translate(
                            context,
                            "homepage.library_card.no_info",
                          )
                        : FlutterI18n.translate(
                            context,
                            "homepage.library_card.fetching_info",
                          ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
