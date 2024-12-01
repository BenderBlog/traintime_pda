// Copyright 2023 BenderBlog Rodriguez and contributors.
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
  const BookInfoCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return [
      CachedNetworkImage(
        imageUrl: LibrarySession.bookCover(toUse.isbn ?? ""),
        placeholder: (context, url) => Image.asset(
          "assets/art/pda_empty_cover.jpg",
          width: 176 * 0.6,
          height: 250 * 0.6,
          fit: BoxFit.fill,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "assets/art/pda_empty_cover.jpg",
          width: 176 * 0.6,
          height: 250 * 0.6,
          fit: BoxFit.fill,
        ),
        width: 176 * 0.6,
        height: 250 * 0.6,
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
        errorListener: (e) {
          if (e is DioException) {
            log.info('Error with Internet error...');
          } else {
            log.info('Image Exception is: ${e.runtimeType}');
          }
        },
      ).clipRRect(all: 14),
      const VerticalDivider(color: Colors.transparent),
      [
        Text(
          '${toUse.bookName}\n',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(children: [
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
              text: toUse.author ??
                  FlutterI18n.translate(
                    context,
                    "library.not_provided",
                  ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text.rich(TextSpan(children: [
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
            text: toUse.publisherHouse ??
                FlutterI18n.translate(
                  context,
                  "library.not_provided",
                ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ])),
        Text.rich(TextSpan(children: [
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
            text: toUse.searchCodeStr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ])),
        [
          [
            Text.rich(TextSpan(children: [
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
            ])),
            const Text(
              " / ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: toUse.items?.length.toString() ?? "0",
                style: TextStyle(
                  fontSize: 24,
                  color: (toUse.items?.length ?? 0) > 0
                      ? Colors.green
                      : Colors.yellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: FlutterI18n.translate(
                  context,
                  "library.storage",
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBFBFBF),
                ),
              ),
            ])),
          ].toRow(),
        ].toRow(mainAxisAlignment: MainAxisAlignment.end),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
          .center()
          .expanded()
    ].toRow().padding(all: 12).card(elevation: 0);
  }
}
