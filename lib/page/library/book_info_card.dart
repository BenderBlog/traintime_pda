/*
Library info card.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

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
        horizontal: 10,
        vertical: 5,
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          Text(
            "${toUse.author} ${toUse.publisherHouse}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: CachedNetworkImage(
                  imageUrl: LibrarySession.bookCover(toUse.isbn!),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Image.asset("assets/Empty-Cover.jpg"),
                  width: 90,
                  height: 120,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("馆藏量：${toUse.bookNumber}"),
                  Text("ISBN: ${toUse.isbn}"),
                  Text("发行时间: ${toUse.publicationDate}"),
                  Text("索书号: ${toUse.searchCode}"),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
