// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class FilmComponent extends StatelessWidget {
  static const sideWidthRatio = 0.06;
  static const middleWidthRatio = 0.88;
  static const sideBoxRatio = 36 / 52;
  static const sidePaddingRatio = 8 / 52;
  static const sideRadiusRatio = 8 / 36;
  static const imageVerticalPadding = 4.0;

  static List<String> description = [
    "去这种咖啡厅等于给自己找妈？",
    "每一个呆唯的背后都有一个当妈的妹妹",
    "只能说女孩子之间的感情真好啊",
    "看牙医的你",
    "但是现实的可能更可爱，萌萌哒哒",
    "大学定律：越到期末考试，好玩的事情越多",
  ];

  const FilmComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 800.0;
        final sideWidth = availableWidth * sideWidthRatio;
        final middleWidth = availableWidth * middleWidthRatio;

        return SizedBox(
          width: availableWidth,
          child: CustomPaint(
            painter: _FilmPainter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              sideWidth: sideWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sideWidth),
              child: SizedBox(
                width: middleWidth,
                child: Column(
                  children: List.generate(
                    6,
                    (i) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: imageVerticalPadding,
                      ),
                      child: FilmFrame(
                        image: Image.asset(
                          "assets/art/lucky_star_${i + 1}.jpg",
                          fit: BoxFit.fill,
                        ),
                        text: description[i],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilmPainter extends CustomPainter {
  const _FilmPainter({required this.color, required this.sideWidth});

  final Color color;
  final double sideWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (sideWidth <= 0) {
      return;
    }

    final boxSize = sideWidth * FilmComponent.sideBoxRatio;
    final padding = sideWidth * FilmComponent.sidePaddingRatio;
    final boxCount = size.height ~/ sideWidth;
    final verticalOffset = (size.height - boxCount * sideWidth) / 2;
    final paint = Paint()..color = color;
    final radius = Radius.circular(boxSize * FilmComponent.sideRadiusRatio);

    for (var index = 0; index < boxCount; index++) {
      final top = verticalOffset + index * sideWidth + padding;
      final leftRect = Rect.fromLTWH(padding, top, boxSize, boxSize);
      final rightRect = Rect.fromLTWH(
        size.width - sideWidth + padding,
        top,
        boxSize,
        boxSize,
      );

      canvas.drawRRect(RRect.fromRectAndRadius(leftRect, radius), paint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightRect, radius), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FilmPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.sideWidth != sideWidth;
  }
}

class FilmFrame extends StatelessWidget {
  static const _imageRadius = 16.0;

  final String? text;
  final Image image;
  const FilmFrame({super.key, required this.image, this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_imageRadius),
      child: Stack(
        alignment: AlignmentGeometry.topCenter,
        children: [
          image,

          if (text != null)
            Container(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
              width: double.infinity,
              child: Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
