// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library info card.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BookInfoCard extends StatelessWidget {
  final BookInfo toUse;
  const BookInfoCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: Text(toUse.bookName),
      remaining: const [],
      bottomRow: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: CachedNetworkImage(
              imageUrl: LibrarySession.bookCover(toUse.isbn ?? ""),
              errorWidget: (context, url, error) =>
                  Image.asset("assets/Empty-Cover.jpg"),
              width: 90,
              height: 120,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "作者：${toUse.author ?? "没有相关信息"}",
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "出版社：${toUse.publisherHouse ?? "没有相关信息"}",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "馆藏量：${toUse.items?.length ?? "没有相关信息"}",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "ISBN: ${toUse.isbn ?? "没有相关信息"}",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "发行时间: ${toUse.publishYear ?? "没有相关信息"}",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "索书号: ${validateList(toUse.searchCode)}",
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String validateList(List<String>? inputList) {
  if (inputList == null || inputList.isEmpty) {
    return "没有相关信息";
  }
  return inputList.first;
}

}
