// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_place_card.dart';
import 'package:watermeter/page/library/ebook_place_card.dart';
import 'package:watermeter/repository/logger.dart';
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
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CachedNetworkImage(
              imageUrl: LibrarySession.bookCover(widget.toUse.isbn ?? ""),
              placeholder: (context, url) => Image.asset(
                "assets/Empty-Cover.jpg",
                width: 120,
                height: 150,
                fit: BoxFit.fill,
              ),
              errorWidget: (context, url, error) => Image.asset(
                "assets/Empty-Cover.jpg",
                width: 120,
                height: 150,
                fit: BoxFit.fill,
              ),
              width: 120,
              height: 150,
              fit: BoxFit.fitHeight,
              alignment: Alignment.center,
              errorListener: (e) {
                if (e is DioException) {
                  log.info('Error with Internet error...');
                } else {
                  log.info('Image Exception is: ${e.runtimeType}');
                }
              },
            )
                //.clipRect(clipper: BookImageClipper())
                .clipRRect(all: 14)
                .padding(all: 2)
                .decorated(
                  border: Border.all(color: const Color(0xFFE8E8E8), width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                )
                .padding(right: 12),
            [
              Text(
                widget.toUse.bookName,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(
                    text: "作者 ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBFBFBF),
                    ),
                  ),
                  TextSpan(
                    text: widget.toUse.author ?? "没有提供",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
              ),
              Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "出版社 ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBFBFBF),
                  ),
                ),
                TextSpan(
                  text: widget.toUse.publisherHouse ?? "没有相关信息",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "索书号 ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBFBFBF),
                  ),
                ),
                TextSpan(
                  text: widget.toUse.searchCodeStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "发行时间 ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBFBFBF),
                  ),
                ),
                TextSpan(
                  text: widget.toUse.publishYear ?? "没有相关信息",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "ISBN ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBFBFBF),
                  ),
                ),
                TextSpan(
                  text: widget.toUse.isbn ?? "没有提供",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "编排号码 ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBFBFBF),
                  ),
                ),
                TextSpan(
                  text: widget.toUse.barCodesStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ])),
            ]
                .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
                .flexible(),
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
    );
  }
}
