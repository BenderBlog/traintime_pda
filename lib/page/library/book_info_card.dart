// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Library info card.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
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
    return [
      CachedNetworkImage(
        imageUrl: LibrarySession.bookCover(toUse.isbn ?? ""),
        placeholder: (context, url) => Image.asset(
          "assets/Empty-Cover.jpg",
          width: 176 * 0.75,
          height: 250 * 0.75,
          fit: BoxFit.fill,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "assets/Empty-Cover.jpg",
          width: 176 * 0.75,
          height: 250 * 0.75,
          fit: BoxFit.fill,
        ),
        width: 176 * 0.75,
        height: 250 * 0.75,
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
      )
          //.clipRect(clipper: BookImageClipper())
          .clipRRect(all: 14)
          .padding(all: 2)
          .decorated(
              border: Border.all(color: const Color(0xFFE8E8E8), width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
            const BoxShadow(
              color: Color(0xFFE8E8E8),
              blurRadius: 14,
            ),
          ]),
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
            const TextSpan(
              text: "作者 ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFBFBFBF),
              ),
            ),
            TextSpan(
              text: toUse.author ?? "没有提供",
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
          const TextSpan(
            text: "出版社 ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBFBFBF),
            ),
          ),
          TextSpan(
            text: toUse.publisherHouse ?? "没有相关信息",
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
              const TextSpan(
                text: "可借",
                style: TextStyle(
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
              const TextSpan(
                text: "馆藏",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBFBFBF),
                ),
              ),
            ])),
          ].toRow(),
          /*
          Text.rich(TextSpan(children: [
            TextSpan(
              text: toUse.publishYear?.substring(0, 4) ?? "没有相关信息",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(
              text: " 发行时间",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFBFBFBF),
              ),
            ),
          ])),
          */
        ].toRow(mainAxisAlignment: MainAxisAlignment.end),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
          .center()
          .padding(all: 12)
          .backgroundColor(Colors.white)
          .clipRRect(topRight: 14, bottomRight: 14)
          .decorated(boxShadow: [
        const BoxShadow(
          color: Color(0xFFE8E8E8),
          blurRadius: 14,
        ),
      ]).expanded()
    ].toRow().padding(all: 8);
  }

  String validateList(List<String>? inputList) {
    if (inputList == null || inputList.isEmpty) {
      return "没有相关信息";
    }
    return inputList.first;
  }
}
