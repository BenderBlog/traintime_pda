// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Library borrow card.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BorrowInfoCard extends StatelessWidget {
  final BorrowData toUse;
  const BorrowInfoCard({super.key, required this.toUse});

  @override
  Widget build(BuildContext context) {
    return [
      FutureBuilder<String>(
        future: LibrarySession()
            .searchBook(toUse.barcode, 1, searchField: "barcode")
            .then((books) => books.isNotEmpty
                ? LibrarySession().bookCover(
                    books.first.bookName,
                    books.first.isbn ?? "",
                    books.first.docNumber,
                  )
                : Future.value("")),
        builder: (context, snapshot) {
          return CachedNetworkImage(
            imageUrl: snapshot.data ?? "",
        placeholder: (context, url) => Image.asset(
          "assets/art/pda_empty_cover.jpg",
          width: 176 * 0.5,
          height: 250 * 0.5,
          fit: BoxFit.fitHeight,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "assets/art/pda_empty_cover.jpg",
          width: 176 * 0.5,
          height: 250 * 0.5,
          fit: BoxFit.fitHeight,
        ),
        width: 176 * 0.5,
        height: 250 * 0.5,
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
        errorListener: (e) {
          if (e is DioException) {
            log.info('Error with Internet error...');
          } else {
            log.info('Image Exception is: ${e.runtimeType}');
          }
        },
      );
        },
      )
      //.clipRect(clipper: BookImageClipper())
      .clipRRect(all: 14),
      const VerticalDivider(),
      [
            Text(
              toUse.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ).padding(top: 10),
            const SizedBox(height: 12),
            [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${toUse.loanDateTime.year}\n",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                        TextSpan(
                          text: DateFormat("M/dd").format(toUse.loanDateTime),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    TextSpan(
                      text: FlutterI18n.translate(
                        context,
                        "library.borrow_str",
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 26,
                height: 16,
                child: List.generate(
                  150 ~/ 10,
                  (index) => Expanded(
                    child: Container(
                      color: index % 2 == 0 ? Colors.transparent : Colors.grey,
                      height: 2,
                    ),
                  ),
                ).toRow(),
              ).padding(horizontal: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${toUse.normReturnDateTime.year}\n",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    TextSpan(
                      text: DateFormat("M/dd").format(toUse.normReturnDateTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: FlutterI18n.translate(context, "library.due_date"),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                bool isOverdue = false;
                if (toUse.lendDay < 0) {
                  isOverdue = true;
                }
                final text = Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: toUse.lendDay.abs().toString(),
                        style: TextStyle(
                          fontSize: 24,
                          color: toUse.lendDay < 1
                              ? Colors.red
                              : toUse.lendDay < 3
                              ? Colors.yellow
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: isOverdue
                            ? FlutterI18n.translate(
                                context,
                                "library.after_due_date",
                              )
                            : FlutterI18n.translate(
                                context,
                                "library.before_due_date",
                              ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ).padding(bottom: 10);
                final button = TextButton(
                  onPressed: () {
                    if (!isOverdue) {
                      ProgressDialog pd = ProgressDialog(context: context);
                      pd.show(
                        msg: FlutterI18n.translate(context, "library.renewing"),
                      );
                      LibrarySession().renew(toUse).then((value) {
                        if (context.mounted) {
                          pd.close();
                          showToast(context: context, msg: value);
                        }
                      });
                    }
                  },
                  child: Text(
                    isOverdue
                        ? FlutterI18n.translate(
                            context,
                            "library.cannot_be_renewable",
                          )
                        : FlutterI18n.translate(
                            context,
                            "library.can_be_renewable",
                          ),
                  ),
                );
                return [text, button].toRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                );
              },
            ),
          ]
          .toColumn(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          )
          .expanded(),
    ].toRow().padding(horizontal: 12, vertical: 4).card(elevation: 0);
  }
}
