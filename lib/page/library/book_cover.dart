// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/repository/logger.dart';

class BookCover extends StatefulWidget {
  final String bookName;
  final String? isbn;
  final int docNumber;
  final String? knownImageUrl;
  final double width;

  const BookCover({
    super.key,
    required this.bookName,
    this.isbn,
    required this.docNumber,
    this.knownImageUrl,
    this.width = 176 * 0.6,
  });

  @override
  State<BookCover> createState() => _BookCoverState();
}

class _BookCoverState extends State<BookCover> {
  late Future<String> _coverFuture;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _coverFuture = _loadCover();
    _imageUrl = widget.knownImageUrl;
  }

  @override
  void didUpdateWidget(covariant BookCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookName != widget.bookName ||
        oldWidget.isbn != widget.isbn ||
        oldWidget.docNumber != widget.docNumber) {
      _coverFuture = _loadCover();
    }
  }

  Future<String> _loadCover() {
    final imageUrl = _imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Future.value(imageUrl);
    }
    return LibraryController.i.session.bookCover(
      widget.bookName,
      widget.isbn ?? "",
      widget.docNumber,
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
        _imageUrl = url;
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
