// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_place_card.dart';
import 'package:watermeter/page/library/ebook_place_card.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BookDetailCard extends StatefulWidget {
  final BookInfo toUse;

  const BookDetailCard({
    super.key,
    required this.toUse,
  });

  @override
  State<BookDetailCard> createState() => _BookDetailCardState();
}

class _BookDetailCardState extends State<BookDetailCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.toUse.bookName,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                    Text(
                      "作者：${widget.toUse.author ?? "没有提供"}\n"
                      "ISBN：${widget.toUse.isbn ?? "没有提供"}\n"
                      "索书号: ${validateList(widget.toUse.searchCode)}\n"
                      "编排号码：${validateList(widget.toUse.barCodes)}\n"
                      "描述：${widget.toUse.description ?? "没有提供"}",
                    ),
                  ],
                ),
              ),
              CachedNetworkImage(
                imageUrl: LibrarySession.bookCover(widget.toUse.isbn ?? ""),
                errorWidget: (context, url, error) =>
                    Image.asset("assets/Empty-Cover.jpg"),
                width: 90,
                height: 120,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.toUse.items != null)
                  ...List.generate(
                    widget.toUse.items!.length,
                    (index) => BookPlaceCard(
                      toUse: widget.toUse.items![index],
                    ),
                  ),
                if (widget.toUse.eitems != null)
                  ...List.generate(
                    widget.toUse.eitems!.length,
                    (index) => EBookPlaceCard(
                      toUse: widget.toUse.eitems![index],
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
    String validateList(List<String>? inputList) {
  if (inputList == null || inputList.isEmpty) {
    return "没有提供";
  }
  return inputList.first;
}
}
