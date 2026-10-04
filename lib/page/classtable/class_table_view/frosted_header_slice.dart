// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// A frosted header backdrop slice with edge stretch and linear alpha feathering.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui show ImageFilter;

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// A frosted glass header slice whose bottom edge smoothly dissolves into the content area below.
///
/// When a background [imageFile] is provided, it extracts the top 1~5 pixels of the wallpaper,
/// stretches them vertically across the header, and applies a true Gaussian blur. This ensures the
/// fixed header carries the harmonious ambient colors and lighting of the wallpaper without
/// obscuring foreground subjects, heads, or portraits.
///
/// At the bottom of the header, a linear alpha mask ([ShaderMask] with [BlendMode.dstIn])
/// feathers down to 0% opacity over [featherHeight] (20~30dp), creating a seamless transition into
/// the sharp wallpaper in the timetable area below.
class FrostedHeaderSlice extends StatelessWidget {
  const FrostedHeaderSlice({
    super.key,
    required this.headerHeight,
    this.featherHeight = frostedHeaderFeatherHeight,
    required this.sigma,
    required this.tintColor,
    this.imageFile,
    this.imageRevision,
  });

  /// The solid height of the frosted header (e.g. status bar + app bar + docked week bar).
  final double headerHeight;

  /// The vertical length of the feathering region below [headerHeight] over which the blur
  /// and tint fade to completely transparent.
  final double featherHeight;

  /// Blur strength in logical pixels.
  final double sigma;

  /// Surface tint color painted over the blurred backdrop.
  final Color tintColor;

  /// The user wallpaper image file. When provided, extracts the top edge pixels of the wallpaper,
  /// stretches them vertically across the header, and blurs them as an ambient frosted background.
  final File? imageFile;

  /// Revision identifier for [imageFile] to ensure cache invalidation.
  final String? imageRevision;

  @override
  Widget build(BuildContext context) {
    if (headerHeight <= 0 && featherHeight <= 0) {
      return const SizedBox.shrink();
    }

    final bool hasImage = imageFile != null && imageFile!.existsSync();

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double currentHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : headerHeight + featherHeight;

          if (currentHeight <= 0) {
            return const SizedBox.shrink();
          }

          final double effectiveWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;

          Widget content;
          if (hasImage) {
            final double blurSigma = math.max(sigma, 16.0);
            content = Stack(
              fit: StackFit.expand,
              children: [
                /// Extracts the top 4 logical pixels of the wallpaper, stretches them vertically
                /// across the header, and applies a true Gaussian blur.
                ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                    tileMode: TileMode.clamp,
                  ),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: effectiveWidth,
                      height: 4.0,
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        maxHeight: double.infinity,
                        maxWidth: double.infinity,
                        child: Image.file(
                          imageFile!,
                          key: imageRevision != null
                              ? ValueKey<String>(
                                  "${imageFile!.path}:$imageRevision:edge",
                                )
                              : null,
                          width: effectiveWidth,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Translucent surface tint.
                ColoredBox(color: tintColor),
              ],
            );
          } else {
            content = ColoredBox(color: tintColor);
          }

          return ClipRect(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (Rect bounds) {
                if (bounds.height <= 0 || featherHeight <= 0) {
                  return const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ).createShader(bounds);
                }

                final double effectiveFeather = math.min(
                  featherHeight,
                  bounds.height,
                );
                final double solidHeight = math.max(
                  0.0,
                  bounds.height - effectiveFeather,
                );
                final double solidFraction = (solidHeight / bounds.height).clamp(
                  0.0,
                  1.0,
                );

                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, solidFraction, 1.0],
                  colors: const [
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                ).createShader(bounds);
              },
              child: content,
            ),
          );
        },
      ),
    );
  }
}
