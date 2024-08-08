// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library borrow card.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BorrowInfoCard extends StatelessWidget {
  final BorrowData toUse;
  const BorrowInfoCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return [
      CachedNetworkImage(
        imageUrl: LibrarySession.bookCover(toUse.isbn),
        placeholder: (context, url) => Image.asset(
          "assets/Empty-Cover.jpg",
          width: 176 * 0.75,
          height: 250 * 0.75,
          fit: BoxFit.fill,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "assets/Empty-Cover.jpg",
          width: 176 * 0.75,
          height: 250 * 0.75,
          fit: BoxFit.fill,
        ),
        width: 176 * 0.75,
        height: 250 * 0.75,
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
      )
          //.clipRect(clipper: BookImageClipper())
          .clipRRect(all: 14)
          .padding(all: 2)
          .decorated(
              border: Border.all(color: const Color(0xFFE8E8E8), width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
            const BoxShadow(
              color: Color(0xFFE8E8E8),
              blurRadius: 14,
            ),
          ]),
      [
        Text(
          '${toUse.title}\n',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        [
          Text.rich(TextSpan(children: [
            TextSpan(children: [
              TextSpan(
                text: "${toUse.loanDateTime.year}\n",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              TextSpan(
                text: toUse.loanDateTime.format(pattern: 'M/dd'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            ]),
            const TextSpan(
              text: " 借阅",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ])),
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
          Text.rich(TextSpan(children: [
            TextSpan(
              text: "${toUse.normReturnDateTime.year}\n",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            TextSpan(
              text: toUse.normReturnDateTime.format(pattern: 'M/dd'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(
              text: " 到期",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ])),
        ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
        const SizedBox(height: 12),
        Builder(builder: (context) {
          bool isOverdue = false;
          if (toUse.lendDay < 0) {
            isOverdue = true;
          }
          final text = Text.rich(TextSpan(children: [
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
              text: isOverdue ? "天前过期" : "天后",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFBFBFBF),
              ),
            ),
          ]));
          final button = Text(
            isOverdue ? "不可续借" : "续借",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          )
              .padding(horizontal: 12, vertical: 8)
              .backgroundColor(isOverdue
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary)
              .clipRRect(all: 12)
              .gestures(
            onTap: () {
              if (!isOverdue) {
                ProgressDialog pd = ProgressDialog(context: context);
                pd.show(msg: "正在续借");
                LibrarySession().renew(toUse.loanId).then((value) {
                  pd.close();
                  showToast(context: context, msg: value);
                });
              }
            },
          );
          return [
            text,
            button,
          ].toRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
          );
        }),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
          .center()
          .padding(all: 12)
          .backgroundColor(Colors.white)
          .clipRRect(topRight: 14, bottomRight: 14)
          .decorated(boxShadow: [
        const BoxShadow(
          color: Color(0xFFE8E8E8),
          blurRadius: 14,
        ),
      ]).expanded()
    ].toRow().padding(all: 8);
  }
}
