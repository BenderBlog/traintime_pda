// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The blurred wallpaper, baked once, and the crop each control paints from it.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// Bakes the table's wallpaper into a blurred texture and hands it to the controls below.
///
/// The blur is a mipmap blur: the file is decoded at a quarter of its display width, blurred at that
/// size, and baked at half the display size, so the gaussian runs over a small image and the upscale
/// does the rest. It happens once per box size and is then cached.
///
/// A control does not blur anything itself: it paints the crop of this texture that sits behind it
/// (see [FrostedCardBackground]). That is the whole point — a tableful of cards sliding and being
/// dragged costs one image draw each, not hundreds of backdrop reads per second.
class FrostedWallpaper extends StatefulWidget {
  const FrostedWallpaper({
    super.key,
    required this.file,
    required this.sheetTop,
    required this.pageOffset,
    required this.child,
  });

  /// The wallpaper file to blur.
  final File file;

  /// Where the table sheet starts, measured from the top of the wallpaper.
  final double sheetTop;

  /// How far the week pages are scrolled, in pixels.
  final ValueListenable<double> pageOffset;

  final Widget child;

  @override
  State<FrostedWallpaper> createState() => _FrostedWallpaperState();
}

class _FrostedWallpaperState extends State<FrostedWallpaper> {
  /// Baked textures, keyed by the file and the size they were baked for.
  static final Map<String, ui.Image> _baked = <String, ui.Image>{};

  static const int _keep = 4;

  ui.Image? _image;
  String? _wanted;

  @override
  void dispose() {
    /// The textures are shared between rebuilds, so they outlive this widget.
    super.dispose();
  }

  String _key(Size size) {
    int modified = 0;
    int length = 0;
    try {
      final FileStat stat = widget.file.statSync();
      modified = stat.modified.millisecondsSinceEpoch;
      length = stat.size;
    } catch (_) {
      /// Reported as a plain background by the bake itself.
    }
    return '${widget.file.path}|$modified|$length|${GlassStyleConfig.cardSigma}'
        '|${size.width.round()}x${size.height.round()}';
  }

  void _request(Size size) {
    if (size.isEmpty) {
      return;
    }
    final String key = _key(size);
    if (key == _wanted) {
      return;
    }
    _wanted = key;
    final ui.Image? ready = _baked[key];
    if (ready != null) {
      _image = ready;
      return;
    }

    /// Whatever is on screen stays there while the new size bakes.
    _bake(size, key);
  }

  Future<void> _bake(Size size, String key) async {
    final ui.Image? baked = await _blurWallpaper(widget.file, size);
    if (baked == null) {
      return;
    }
    _baked[key] = baked;
    if (_baked.length > _keep) {
      /// Dropped rather than disposed: another size may still be painting it.
      _baked.remove(_baked.keys.first);
    }
    if (!mounted || _wanted != key) {
      return;
    }
    setState(() => _image = baked);
  }

  static Future<ui.Image?> _blurWallpaper(File file, Size size) async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(
        await file.readAsBytes(),
        targetWidth: (size.width * wallpaperDecodeScale).round().clamp(1, 4096),
      );
      final ui.Image source = (await codec.getNextFrame()).image;
      codec.dispose();

      /// Baked at the wallpaper's own aspect ratio and placed with [BoxFit.cover] when it is drawn,
      /// so the blur never stretches it.
      final int width = (size.width * wallpaperBakeScale).round().clamp(1, 4096);
      final int height = (width * source.height / source.width)
          .round()
          .clamp(1, 4096);
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        source,
        ui.Rect.fromLTWH(
          0,
          0,
          source.width.toDouble(),
          source.height.toDouble(),
        ),
        ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        ui.Paint()
          ..filterQuality = ui.FilterQuality.low
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: GlassStyleConfig.cardSigma * wallpaperBakeScale,
            sigmaY: GlassStyleConfig.cardSigma * wallpaperBakeScale,
            tileMode: ui.TileMode.clamp,
          ),
      );
      final ui.Picture picture = recorder.endRecording();
      final ui.Image baked = await picture.toImage(width, height);
      picture.dispose();
      source.dispose();
      return baked;
    } catch (_) {
      /// A wallpaper that cannot be read or decoded leaves the controls on their plain tint.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _request(constraints.biggest);
        return FrostedWallpaperScope(
          image: _image,
          box: constraints.biggest,
          sheetTop: widget.sheetTop,
          pageOffset: widget.pageOffset,
          child: widget.child,
        );
      },
    );
  }
}

/// The baked wallpaper and the geometry a crop has to be placed with.
class FrostedWallpaperScope extends InheritedWidget {
  const FrostedWallpaperScope({
    super.key,
    required this.image,
    required this.box,
    required this.sheetTop,
    required this.pageOffset,
    required super.child,
  });

  /// The blurred wallpaper, or null before the bake has finished.
  final ui.Image? image;

  /// The box the wallpaper is painted into, which is what [BoxFit.cover] is measured against.
  final Size box;

  /// Where the sheet starts, measured from the top of [box].
  final double sheetTop;

  /// The week pages' scroll offset, in pixels.
  final ValueListenable<double> pageOffset;

  static FrostedWallpaperScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FrostedWallpaperScope>();

  @override
  bool updateShouldNotify(FrostedWallpaperScope oldWidget) =>
      oldWidget.image != image ||
      oldWidget.box != box ||
      oldWidget.sheetTop != sheetTop ||
      oldWidget.pageOffset != pageOffset;
}

/// How the sheet's own content maps onto the wallpaper.
///
/// Provided by the sheet, which is the only place that knows both numbers: the space it reserves at
/// the top of its content and how far that content is scrolled.
class FrostedSheetGeometry extends InheritedWidget {
  const FrostedSheetGeometry({
    super.key,
    required this.pageWidth,
    required this.contentTop,
    required super.child,
  });

  /// The width of one week page.
  final double pageWidth;

  /// Where the sheet's content starts, relative to the sheet: the reserved space minus the scroll
  /// offset. Updated as the table scrolls.
  final ValueListenable<double> contentTop;

  static FrostedSheetGeometry? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FrostedSheetGeometry>();

  @override
  bool updateShouldNotify(FrostedSheetGeometry oldWidget) =>
      oldWidget.pageWidth != pageWidth || oldWidget.contentTop != contentTop;
}

/// A control's own background: the crop of the blurred wallpaper that sits behind it.
///
/// [origin] is where the control sits in the sheet's content, in pixels, measured from the start of
/// the grid; [pageIndex] is its week page, for the controls that page with the table. The wallpaper
/// does not move when the table scrolls, which is exactly why the offset has to be taken off here:
/// the crop has to follow the control as the content slides over the wallpaper.
class FrostedCardBackground extends StatelessWidget {
  const FrostedCardBackground({
    super.key,
    required this.origin,
    required this.pageIndex,
    this.inset = Offset.zero,
    this.child,
  });

  /// The control's top left in the grid's coordinates.
  final Offset origin;

  /// The week page the control belongs to.
  final int pageIndex;

  /// Added to [origin], for a control that is inset inside its slot.
  final Offset inset;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final FrostedWallpaperScope? wallpaper = FrostedWallpaperScope.maybeOf(
      context,
    );
    final FrostedSheetGeometry? sheet = FrostedSheetGeometry.maybeOf(context);
    final ui.Image? image = wallpaper?.image;

    /// Nothing baked yet, or a control that is not part of the table: plain tint, no filter.
    if (wallpaper == null || sheet == null || image == null) {
      return child ?? const SizedBox.expand();
    }

    return CustomPaint(
      painter: _FrostedCropPainter(
        image: image,
        box: wallpaper.box,
        sheetTop: wallpaper.sheetTop,
        pageOffset: wallpaper.pageOffset,
        pageWidth: sheet.pageWidth,
        contentTop: sheet.contentTop,
        origin: origin + inset,
        pageIndex: pageIndex,
      ),
      child: child,
    );
  }
}

class _FrostedCropPainter extends CustomPainter {
  _FrostedCropPainter({
    required this.image,
    required this.box,
    required this.sheetTop,
    required this.pageOffset,
    required this.pageWidth,
    required this.contentTop,
    required this.origin,
    required this.pageIndex,
  }) : super(
         repaint: Listenable.merge([pageOffset, contentTop]),
       );

  final ui.Image image;
  final Size box;
  final double sheetTop;
  final ValueListenable<double> pageOffset;
  final double pageWidth;
  final ValueListenable<double> contentTop;
  final Offset origin;
  final int pageIndex;

  @override
  void paint(Canvas canvas, Size size) {
    /// Where this control sits on the wallpaper, in the wallpaper's own pixels.
    final FittedSizes fitted = applyBoxFit(
      BoxFit.cover,
      Size(image.width.toDouble(), image.height.toDouble()),
      box,
    );
    final Rect painted = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & box,
    );
    final double scale = painted.width / fitted.source.width;
    if (scale <= 0) {
      return;
    }

    final Offset at = Offset(
      origin.dx + pageIndex * pageWidth - pageOffset.value - painted.left,
      origin.dy + sheetTop + contentTop.value - painted.top,
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
        at.dx / scale,
        at.dy / scale,
        size.width / scale,
        size.height / scale,
      ),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  @override
  bool shouldRepaint(covariant _FrostedCropPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.box != box ||
      oldDelegate.sheetTop != sheetTop ||
      oldDelegate.pageWidth != pageWidth ||
      oldDelegate.origin != origin ||
      oldDelegate.pageIndex != pageIndex;
}
