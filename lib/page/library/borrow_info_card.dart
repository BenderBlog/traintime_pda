// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Library borrow card.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/page/library/book_cover.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';

class BorrowInfoCard extends StatelessWidget {
  final BorrowData toUse;
  final BoxConstraints constraints;

  const BorrowInfoCard({
    super.key,
    required this.toUse,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return [
      BookCover(
        key: ValueKey(toUse.loanId),
        bookName: toUse.title,
        docNumber: toUse.recordId,
        isbn: toUse.isbn,
        width: constraints.maxWidth - 16,
      ).clipRRect(all: 6),
      Text(
        toUse.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ).padding(vertical: 8),
      [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: DateFormat("yyyy/M/dd").format(toUse.loanDateTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: FlutterI18n.translate(context, "library.borrow_str"),
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
                text: DateFormat("yyyy/M/dd").format(toUse.normReturnDateTime),
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
      ].toColumn(mainAxisAlignment: MainAxisAlignment.spaceBetween),
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
                      ? FlutterI18n.translate(context, "library.after_due_date")
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
                LibraryController.i.session.renew(toUse).then((value) {
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
                  : FlutterI18n.translate(context, "library.can_be_renewable"),
            ),
          );
          return [text, button].toColumn(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
          );
        },
      ),
    ].toColumn().padding(all: 12).card(elevation: 0);
  }
}
