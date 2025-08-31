// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class ClubImageView extends StatefulWidget {
  final List<ImageProvider> images;
  final Color color;
  final int initalPage;
  const ClubImageView({
    super.key,
    required this.images,
    required this.color,
    required this.initalPage,
  });

  @override
  State<ClubImageView> createState() => _ClubImageViewState();
}

class _ClubImageViewState extends State<ClubImageView> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: widget.color,
          brightness: Theme.of(context).brightness,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            FlutterI18n.translate(context, "club_promotion.picture_preview"),
          ),
        ),
        body: ExtendedImageGesturePageView.builder(
          controller: ExtendedPageController(
            initialPage: widget.initalPage,
            pageSpacing: 50,
          ),
          itemCount: widget.images.length,
          itemBuilder: (BuildContext context, int index) {
            return ExtendedImage(
              image: widget.images[index],
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (ExtendedImageState state) {
                return GestureConfig(
                  inPageView: true,
                  initialScale: 1.0,
                  maxScale: 5.0,
                  animationMaxScale: 6.0,
                  initialAlignment: InitialAlignment.center,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
