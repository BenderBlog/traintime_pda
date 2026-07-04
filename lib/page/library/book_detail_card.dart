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

class BookDetailCard extends StatefulWidget {
  final BookInfo toUse;
  final bool showBorrowAction;
  final void Function(BuildContext context, BookInfo bookInfo)? onBorrowRequest;

  const BookDetailCard({
    super.key,
    required this.toUse,
    this.showBorrowAction = true,
    this.onBorrowRequest,
  });

  @override
  State<BookDetailCard> createState() => _BookDetailCardState();
}

class _BookDetailCardState extends State<BookDetailCard> {
  BookLocation? get _firstBorrowableLocation {
    final items = widget.toUse.items;
    if (items == null) return null;
    for (final item in items) {
      if (item.processType == "在架" && (item.barCode?.isNotEmpty ?? false)) {
        return item;
      }
    }
    return null;
  }

  Widget _buildBorrowAction(BuildContext context) {
    final borrowableLocation = _firstBorrowableLocation;
    if (borrowableLocation == null) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.block),
        label: Text(
          FlutterI18n.translate(context, "library.borrow_unavailable"),
        ),
      );
    }

    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: [
          Icon(
            Icons.warning_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Text(
            FlutterI18n.translate(context, "library.search_borrow_warning"),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ).expanded(),
        ].toRow(),
      ),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: widget.onBorrowRequest == null
            ? null
            : () => widget.onBorrowRequest!(context, widget.toUse),
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(
          FlutterI18n.translate(context, "library.scan_to_borrow_this_book"),
        ),
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CachedNetworkImage(
                  imageUrl: widget.toUse.imageUrl ?? "",
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
                ]
                .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
                .flexible(),
          ],
        ),
        if (widget.showBorrowAction) ...[
          const SizedBox(height: 12),
          _buildBorrowAction(context),
        ],
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
