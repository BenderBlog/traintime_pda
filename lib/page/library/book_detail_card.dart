// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_place_card.dart';
import 'package:watermeter/page/library/ebook_place_card.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BookDetailCard extends StatefulWidget {
  final BookInfo toUse;

  const BookDetailCard({super.key, required this.toUse});

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
            FutureBuilder<String>(
              future: LibrarySession().bookCover(
                widget.toUse.bookName,
                widget.toUse.isbn ?? "",
                widget.toUse.docNumber,
              ),
              builder: (context, snapshot) {
                return CachedNetworkImage(
                  imageUrl: snapshot.data ?? "",
                  placeholder: (context, url) => Image.asset(
                    "assets/art/pda_empty_cover.jpg",
                    width: 120,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/art/pda_empty_cover.jpg",
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
                );
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
                    TextSpan(
                      children: [
                        TextSpan(
                          text: FlutterI18n.translate(
                            context,
                            "library.author",
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.author ??
                              FlutterI18n.translate(
                                context,
                                "library.not_provided",
                              ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: FlutterI18n.translate(
                            context,
                            "library.publish_house",
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.publisherHouse ??
                              FlutterI18n.translate(
                                context,
                                "library.not_provided",
                              ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: FlutterI18n.translate(
                            context,
                            "library.call_number",
                          ),
                          style: const TextStyle(
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
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: FlutterI18n.translate(
                            context,
                            "library.publish_date",
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.publishYear ??
                              FlutterI18n.translate(
                                context,
                                "library.not_provided",
                              ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: FlutterI18n.translate(context, "library.isbn"),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.isbn ??
                              FlutterI18n.translate(
                                context,
                                "library.not_provided",
                              ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: FlutterI18n.translate(
                            context,
                            "library.arrangement_code",
                          ),
                          style: const TextStyle(
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
                      ],
                    ),
                  ),
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
                  (index) => BookPlaceCard(toUse: widget.toUse.items![index]),
                ),
              if (widget.toUse.eitems != null)
                ...List.generate(
                  widget.toUse.eitems!.length,
                  (index) => EBookPlaceCard(toUse: widget.toUse.eitems![index]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
