// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';

class FilmComponent extends StatelessWidget {
  static const sideWidthRatio = 0.06;
  static const middleWidthRatio = 0.88;
  static const sideBoxRatio = 36 / 52;
  static const sidePaddingRatio = 8 / 52;
  static const sideRadiusRatio = 8 / 36;
  static const imageVerticalPadding = 4.0;

  final List<String>? description;
  final List<String> pics;
  final List<Widget>? remainingWidget;

  const FilmComponent({
    super.key,
    this.description,
    required this.pics,
    this.remainingWidget,
  }) : assert(description == null || description.length == pics.length);

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...List.generate(
                      pics.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: imageVerticalPadding,
                        ),
                        child: FilmFrame(
                          image: Image.asset(pics[i], fit: BoxFit.fill),
                          text: description?[i],
                          sideWidth: sideWidth,
                        ),
                      ),
                    ),
                    if (remainingWidget != null && remainingWidget!.isNotEmpty)
                      ...remainingWidget!.map<Widget>(
                        (e) => e.constrained(minWidth: double.infinity),
                      ),
                  ],
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
  final double sideWidth;
  const FilmFrame({
    super.key,
    required this.image,
    this.text,
    required this.sideWidth,
  });

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
              child: Padding(
                padding: EdgeInsets.all(
                  sideWidth * FilmComponent.sideRadiusRatio,
                ),
                child: Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
