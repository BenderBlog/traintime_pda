// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class FilmComponent extends StatelessWidget {
  static const sideWidthRatio = 0.06;
  static const middleWidthRatio = 0.88;
  static const sideBoxRatio = 36 / 52;
  static const sidePaddingRatio = 8 / 52;
  static const sideRadiusRatio = 8 / 36;
  static const imageVerticalPadding = 8.0;

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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImage("assets/art/lucky_star_1.jpg"),
                    _buildImage("assets/art/lucky_star_2.jpg"),
                    _buildImage("assets/art/lucky_star_3.jpg"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String asset) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: imageVerticalPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageVerticalPadding),
        child: Image.asset(asset),
      ),
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
