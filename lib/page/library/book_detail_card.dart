// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_info_card.dart';
import 'package:watermeter/page/library/book_place_card.dart';
import 'package:watermeter/page/library/ebook_place_card.dart';
import 'package:watermeter/generated/l10n.dart';

class BookDetailCard extends StatefulWidget {
  final BookInfo toUse;

  const BookDetailCard({super.key, required this.toUse});

  @override
  State<BookDetailCard> createState() => _BookDetailCardState();
}

class _BookDetailCardState extends State<BookDetailCard> {
  late final Future<List<BookLocation>> _locationsFuture = LibraryController.i
      .loadBookLocations(widget.toUse);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BookCover(toUse: widget.toUse)
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
                          text: I18n.of(context)!.libraryAuthor,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.author ??
                              I18n.of(context)!.libraryNotProvided,
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
                          text: I18n.of(context)!.libraryPublishHouse,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.publisherHouse ??
                              I18n.of(context)!.libraryNotProvided,
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
                          text: I18n.of(context)!.libraryCallNumber,
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
                          text: I18n.of(context)!.libraryPublishDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.publishYear ??
                              I18n.of(context)!.libraryNotProvided,
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
                          text: I18n.of(context)!.libraryIsbn,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFBFBF),
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.toUse.isbn ??
                              I18n.of(context)!.libraryNotProvided,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.toUse.hasBarCodes)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: I18n.of(context)!.libraryArrangementCode,
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
          child: FutureBuilder<List<BookLocation>>(
            future: _locationsFuture,
            builder: (context, snapshot) {
              final locations = snapshot.data ?? const <BookLocation>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: CircularProgressIndicator(),
                    ).padding(vertical: 12),
                  ...List.generate(
                    locations.length,
                    (index) => BookPlaceCard(toUse: locations[index]),
                  ),
                  if (widget.toUse.eitems != null)
                    ...List.generate(
                      widget.toUse.eitems!.length,
                      (index) =>
                          EBookPlaceCard(toUse: widget.toUse.eitems![index]),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
