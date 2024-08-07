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
          width: 120,
          height: 160,
          fit: BoxFit.fill,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "assets/Empty-Cover.jpg",
          width: 120,
          height: 160,
          fit: BoxFit.fill,
        ),
        width: 176 * 0.75,
        height: 250 * 0.75,
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
      ).clipRRect(all: 14).boxShadow(
            color: const Color(0xFFE8E8E8),
            offset: const Offset(0, 0),
            blurRadius: 14,
          ),
      [
        Text(
          toUse.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        [
          [
            Text(
              toUse.loanDateTime.year.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              toUse.loanDateTime.format(pattern: 'MM/dd'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              "借阅",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ].toColumn(),
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
          ).padding(all: 4),
          [
            Text(
              toUse.normReturnDateTime.year.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              toUse.normReturnDateTime.format(pattern: 'MM/dd'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              "到期",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ].toColumn(),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
        [
          Builder(builder: (context) {
            bool isOverdue = false;
            if (toUse.lendDay < 0) {
              isOverdue = true;
            }
            return [
              Text(
                toUse.lendDay.abs().toString(),
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
              Text(
                isOverdue ? "天前过期" : "天后",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBFBFBF),
                ),
              ),
            ].toRow();
          }),
          FilledButton(
            child: const Text("续借"),
            onPressed: () {
              ProgressDialog pd = ProgressDialog(context: context);
              pd.show(msg: "正在续借");
              LibrarySession().renew(toUse.loanId).then((value) {
                pd.close();
                showToast(context: context, msg: value);
              });
            },
          )
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
          .center()
          .padding(top: 8, bottom: 8, right: 8, left: 8)
          .backgroundColor(Colors.grey.shade200)
          .clipRRect(topRight: 14, bottomRight: 14)
          .expanded()
    ].toRow().padding(all: 8);

    /*
    ReXCard(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            toUse.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            "${toUse.author} ${toUse.publisher}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      remaining: [
        ReXCardRemaining(
          toUse.lendDay < 0
              ? "过期 ${toUse.lendDay.abs()} 天"
              : "还有 ${toUse.lendDay} 天",
          color: toUse.lendDay < 1
              ? Colors.red
              : toUse.lendDay < 3
                  ? Colors.yellow
                  : null,
          isBold: toUse.lendDay < 3,
        )
      ],
      bottomRow: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CachedNetworkImage(
                imageUrl: LibrarySession.bookCover(toUse.isbn),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    Image.asset("assets/Empty-Cover.jpg"),
              ).center().expanded(flex: 1),
              const VerticalDivider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("ISBN: ${toUse.isbn}"),
                  Text("馆藏码: ${toUse.barcode}"),
                  Text("借阅日期：${toUse.loanDate}"),
                  Text("到期日期：${toUse.normReturnDate}"),
                  if (toUse.renewDate != null) Text("续借日期：${toUse.renewDate}"),
                  TextButton(
                    child: const Text("按这里续借"),
                    onPressed: () {
                      ProgressDialog pd = ProgressDialog(context: context);
                      pd.show(msg: "正在续借");
                      LibrarySession().renew(toUse.loanId).then((value) {
                        pd.close();
                        showToast(context: context, msg: value);
                      });
                    },
                  ).alignment(Alignment.center),
                ],
              ).expanded(flex: 2),
            ],
          ),
        ],
      ),
    );
    */
  }
}
