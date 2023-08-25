// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// Library info card.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BookInfoCard extends StatelessWidget {
  final BookInfo toUse;
  const BookInfoCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12.5,
        vertical: 9.0,
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              toUse.bookName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Row(
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
                        "作者：${toUse.author}",
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "出版社：${toUse.publisherHouse}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "馆藏量：${toUse.bookNumber}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "ISBN: ${toUse.isbn}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "发行时间: ${toUse.publicationDate}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "索书号: ${toUse.searchCode}",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
