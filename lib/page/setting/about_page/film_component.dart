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
    "先到咸阳为王上，后到咸阳……你马上问问你弟弟，一辆新的斯蒂庞克牌轿车值多少钱？你连这个都不懂，就是陈纳德坐的那种啊～",
    "峨眉峰，还TM独照。颇具浪漫主义气质啊。",
    "我就是看不惯李涯那种……（咬牙切齿）我要是不扳倒他，我在这里算是白混了！",
    "你看看现在，不管保密局还是党通局当官的，嘴上都是主义，那心里都是生意。",
    "余则成赶地主的事情，就这样吧。农民和地主的事情，委员长都管不了，你管得了啊？",
    "现在两根金条放在这里，你能告诉我哪根是高尚的，哪根是龌龊的？别来这套。",
    "把你的脑袋从脚后跟拿出来再用一下吧，想清楚了再告诉我，为啥从箱里面爬出来的是一个叫刘闪的，比你还愚蠢的家伙！",
    "你就是不懂得录音的基本原理，睁开眼睛看看世界吧，就这书《远东情报站》，俩16岁白俄孩子就能搞出来，不是啥复杂的戏法。",
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
                    8,
                    (i) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: imageVerticalPadding,
                      ),
                      child: FilmFrame(
                        image: Image.asset(
                          "assets/art/qianfu_$i.jpg",
                          fit: BoxFit.fill,
                        ),
                        text: description[i],
                        sideWidth: sideWidth,
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
