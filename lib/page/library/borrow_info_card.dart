// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library borrow card.

import 'package:both_side_sheet/both_side_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/transfer_borrow_popout.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BorrowInfoCard extends StatelessWidget {
  final BorrowData toUse;
  const BorrowInfoCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return ReXCard(
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
          "还有 ${toUse.lendDay} 天",
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
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: CachedNetworkImage(
                  imageUrl: LibrarySession.bookCover(toUse.isbn),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Image.asset("assets/Empty-Cover.jpg"),
                  width: 90,
                  height: 120,
                ),
              ),
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
                ],
              ).flexible(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                child: const Text("续借"),
                onPressed: () {
                  ProgressDialog pd = ProgressDialog(context: context);
                  pd.show(msg: "正在续借");
                  LibrarySession().renew(toUse).then((value) {
                    pd.close();
                    showToast(context: context, msg: value);
                  });
                },
              ),
              TextButton(
                child: const Text("转借"),
                onPressed: () => BothSideSheet.show(
                  child: TransferQRCode(data: toUse),
                  title: "转借码",
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
