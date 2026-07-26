// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Library info card.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BookInfoCard extends StatelessWidget {
  final BookInfo toUse;
  final BoxConstraints constraints;
  const BookInfoCard({
    super.key,
    required this.toUse,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return [
      BookCover(
        key: ValueKey(toUse.docNumber),
        toUse: toUse,
        width: constraints.maxWidth - 16,
      ).clipRRect(all: 6),
      const SizedBox(height: 8),
      [
        Text(
          toUse.bookName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: FlutterI18n.translate(context, "library.author"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBFBFBF),
                ),
              ),
              TextSpan(
                text:
                    toUse.author ??
                    FlutterI18n.translate(context, "library.not_provided"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: FlutterI18n.translate(context, "library.publish_house"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBFBFBF),
                ),
              ),
              TextSpan(
                text:
                    toUse.publisherHouse ??
                    FlutterI18n.translate(context, "library.not_provided"),
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
                text: FlutterI18n.translate(context, "library.call_number"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBFBFBF),
                ),
              ),
              TextSpan(
                text: toUse.searchCodeStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        [
          [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: toUse.canBeBorrowed?.toString() ?? "0",
                    style: TextStyle(
                      fontSize: 24,
                      color: (toUse.canBeBorrowed ?? 0) > 0
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: FlutterI18n.translate(
                      context,
                      "library.avaliable_borrow",
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBFBFBF),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              " / ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: toUse.totalStorage?.toString() ?? "0",
                    style: TextStyle(
                      fontSize: 24,
                      color: (toUse.totalStorage ?? 0) > 0
                          ? Colors.green
                          : Colors.yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: FlutterI18n.translate(context, "library.storage"),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBFBFBF),
                    ),
                  ),
                ],
              ),
            ),
          ].toRow(),
        ].toRow(mainAxisAlignment: MainAxisAlignment.end),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
    ].toColumn().padding(all: 12).card(elevation: 0);
  }
}

class BookCover extends StatefulWidget {
  final BookInfo toUse;
  final double width;

  const BookCover({super.key, required this.toUse, this.width = 176 * 0.6});

  @override
  State<BookCover> createState() => _BookCoverState();
}

class _BookCoverState extends State<BookCover> {
  late Future<String> _coverFuture;

  @override
  void initState() {
    super.initState();
    _coverFuture = _loadCover();
  }

  @override
  void didUpdateWidget(covariant BookCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toUse.docNumber != widget.toUse.docNumber ||
        oldWidget.toUse.bookName != widget.toUse.bookName ||
        oldWidget.toUse.isbn != widget.toUse.isbn ||
        oldWidget.toUse.imageUrl != widget.toUse.imageUrl) {
      _coverFuture = _loadCover();
    }
  }

  Future<String> _loadCover() {
    final imageUrl = widget.toUse.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Future.value(imageUrl);
    }
    return LibrarySession().bookCover(
      widget.toUse.bookName,
      widget.toUse.isbn ?? "",
      widget.toUse.docNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _coverFuture,
      builder: (context, snapshot) {
        final url = snapshot.data ?? "";
        if (url.isEmpty) {
          return _emptyCover();
        }
        widget.toUse.imageUrl = url;
        return _networkCover(url);
      },
    );
  }

  Widget _networkCover(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => _emptyCover(),
      errorWidget: (context, url, error) => _emptyCover(),
      width: widget.width,
      fit: BoxFit.fill,
      alignment: Alignment.center,
      errorListener: (e) {
        if (e is DioException) {
          log.info('Error with Internet error...');
        } else {
          log.info('Image Exception is: ${e.runtimeType}');
        }
      },
    );
  }

  Widget _emptyCover() {
    return Image.asset(
      "assets/art/pda_empty_cover.jpg",
      width: widget.width,
      fit: BoxFit.fill,
    );
  }
}
