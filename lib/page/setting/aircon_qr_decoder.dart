// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// Reads the aircon IMEI out of a QR code, from a photo or a camera frame.
//
// The stickers are hard to read: the code uses the lowest error correction
// level, has a logo in the middle and coloured dots printed inside the light
// modules, and sits on the curved front of the aircon. The decoder's own
// binarizer compares each pixel with a small neighbourhood, which turns the
// dots and the logo into enough stray modules to fail the checksum.
//
// Blurring the dots away and thresholding against a much larger neighbourhood
// (or the whole image) reads them, but which blur and window works depends on
// how large the code is in the picture. So several are tried: all of them for
// a photo, and a couple per frame in turn for the camera.

import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_zxing/flutter_zxing.dart';

import 'package:watermeter/controller/aircon_controller.dart';

/// Longest side the photo is decoded at. Large enough to keep a small sticker
/// readable in a full phone photo, small enough to stay fast.
const _maxImageSide = 3000;

typedef AirconQrResult = ({String? imei, bool foundOtherCode});

/// Side of the centred square of a camera frame that is decoded, as a fraction
/// of the frame's shorter side. Decoding less of the frame keeps up with the
/// camera; the scanner page frames this area for the user.
const airconQrScanArea = 0.8;

/// The first plane of a camera frame, copied out of the `CameraImage`.
class AirconQrFrame {
  const AirconQrFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.bytesPerRow,
    required this.isBgra,
  });

  /// The luminance plane for YUV frames, the interleaved pixels for BGRA.
  final Uint8List bytes;
  final int width;
  final int height;
  final int bytesPerRow;
  final bool isBgra;
}

/// Returns the IMEI found in the image at [path], or null if there is none.
Future<String?> decodeAirconImeiFromImageFile(String path) async {
  final bytes = await File(path).readAsBytes();
  // Decode with the engine rather than `package:image`: it handles HEIC photos
  // from iOS and the EXIF orientation of camera pictures.
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final codec = await ui.instantiateImageCodecWithSize(
    buffer,
    getTargetSize: (width, height) {
      final longest = max(width, height);
      if (longest <= _maxImageSide) return ui.TargetImageSize();
      final scale = _maxImageSide / longest;
      return ui.TargetImageSize(
        width: max(1, (width * scale).round()),
        height: max(1, (height * scale).round()),
      );
    },
  );
  final ByteData? rgba;
  final int width, height;
  try {
    final frame = await codec.getNextFrame();
    final image = frame.image;
    width = image.width;
    height = image.height;
    rgba = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    image.dispose();
  } finally {
    codec.dispose();
  }
  if (rgba == null) return null;

  final result = await _decodeRgbaInBackground(rgba, width, height);
  return result.imei;
}

// Kept out of the async function above: a closure there would also capture its
// suspended locals, such as the codec, which cannot be sent to an isolate.
Future<AirconQrResult> _decodeRgbaInBackground(
  ByteData rgba,
  int width,
  int height,
) => Isolate.run(() {
  final image = _luminanceFromRgba(
    rgba.buffer.asUint8List(rgba.offsetInBytes, rgba.lengthInBytes),
    width,
    height,
  );
  return _decode(_photoVariants(image));
});

/// Looks for the IMEI in one camera frame. [frameIndex] picks which of the
/// binarizations are tried, so that consecutive frames cover all of them.
Future<AirconQrResult> decodeAirconImeiFromCameraFrame(
  AirconQrFrame frame,
  int frameIndex,
) => Isolate.run(
  () => _decode(_frameVariants(_luminanceFromFrame(frame), frameIndex)),
);

AirconQrResult _decode(Iterable<_Variant> variants) {
  var foundOtherCode = false;
  for (final variant in variants) {
    final results = zx.readBarcodes(variant.image.bytes, variant.params);
    for (final code in results.codes) {
      final imei = AirconController.tryParseImei(code.text ?? "");
      if (imei != null) return (imei: imei, foundOtherCode: false);
      foundOtherCode = true;
    }
  }
  return (imei: null, foundOtherCode: foundOtherCode);
}

/// A grayscale image, one byte per pixel.
class _Gray {
  const _Gray(this.bytes, this.width, this.height);
  final Uint8List bytes;
  final int width;
  final int height;
}

class _Variant {
  _Variant(
    this.image, {
    int cropLeft = 0,
    int cropTop = 0,
    int cropWidth = 0,
    int cropHeight = 0,
  }) : params = DecodeParams(
         imageFormat: ImageFormat.lum,
         format: Format.matrixCodes,
         width: image.width,
         height: image.height,
         cropLeft: cropLeft,
         cropTop: cropTop,
         cropWidth: cropWidth,
         cropHeight: cropHeight,
         tryHarder: true,
         tryInverted: true,
         tryDownscale: true,
         isMultiScan: true,
       );

  final _Gray image;
  final DecodeParams params;
}

/// Each picked so that together they read the stickers across the range of
/// sizes a code takes up in a photo or a frame.
final List<_Gray Function(_Gray)> _binarizations = [
  (image) => _localThreshold(_boxBlur(image, 1), 0.1),
  (image) => _localThreshold(_boxBlur(image, 2), 0.1),
  (image) => _localThreshold(_boxBlur(image, 2), 0.05),
  (image) => _otsuThreshold(_boxBlur(image, 2)),
  (image) => _localThreshold(_boxBlur(image, 3), 0.2),
  (image) => _otsuThreshold(_boxBlur(image, 3)),
];

Iterable<_Variant> _photoVariants(_Gray image) sync* {
  yield _Variant(image);

  for (final scale in const [1.0, 0.75, 0.5]) {
    final scaled = _scale(image, scale);
    for (final binarize in _binarizations) {
      yield _Variant(binarize(scaled));
    }
  }

  // Screenshots cropped right to the code leave no quiet zone around it.
  yield _Variant(_padWithWhite(image));

  // Narrow the search so other codes and clutter do not get in the way.
  final cropWidth = (image.width * 0.6).round();
  final cropHeight = (image.height * 0.6).round();
  for (final (fx, fy) in const [
    (0.5, 0.5),
    (0.0, 0.0),
    (1.0, 0.0),
    (0.0, 1.0),
    (1.0, 1.0),
  ]) {
    yield _Variant(
      image,
      cropLeft: ((image.width - cropWidth) * fx).round(),
      cropTop: ((image.height - cropHeight) * fy).round(),
      cropWidth: cropWidth,
      cropHeight: cropHeight,
    );
  }
}

/// The frame as is, which reads ordinary codes, then two binarizations. Over
/// consecutive frames these cycle through every binarization at full and at
/// reduced size. Reducing helps once the camera is zoomed in far: the frame is
/// then enlarged from fewer real pixels, and shrinking it sharpens the code.
Iterable<_Variant> _frameVariants(_Gray frame, int frameIndex) sync* {
  yield _Variant(frame);

  final count = _binarizations.length;
  for (var k = 0; k < 2; k++) {
    final i = (frameIndex * 2 + k) % (count * 2);
    final source = i < count ? frame : _scale(frame, 0.6);
    yield _Variant(_binarizations[i % count](source));
  }
}

/// Converts straight RGBA to luminance, drawing transparent pixels as white:
/// a QR code saved as a PNG with a transparent background is otherwise black
/// on black.
_Gray _luminanceFromRgba(Uint8List rgba, int width, int height) {
  final out = Uint8List(width * height);
  for (var i = 0, p = 0; i < out.length; i++, p += 4) {
    final a = rgba[p + 3];
    final l = (299 * rgba[p] + 587 * rgba[p + 1] + 114 * rgba[p + 2]) ~/ 1000;
    out[i] = (l * a + 255 * (255 - a)) ~/ 255;
  }
  return _Gray(out, width, height);
}

/// Copies the centred [airconQrScanArea] of the frame, converting BGRA to
/// luminance.
_Gray _luminanceFromFrame(AirconQrFrame frame) {
  final side = (min(frame.width, frame.height) * airconQrScanArea).round();
  final left = (frame.width - side) ~/ 2, top = (frame.height - side) ~/ 2;
  final src = frame.bytes;
  final out = Uint8List(side * side);
  for (var y = 0; y < side; y++) {
    final row = (top + y) * frame.bytesPerRow;
    final dst = y * side;
    if (!frame.isBgra) {
      out.setRange(dst, dst + side, src, row + left);
      continue;
    }
    for (var x = 0, p = row + left * 4; x < side; x++, p += 4) {
      out[dst + x] =
          (114 * src[p] + 587 * src[p + 1] + 299 * src[p + 2]) ~/ 1000;
    }
  }
  return _Gray(out, side, side);
}

/// Resizes by [scale], averaging the source pixels each target pixel covers.
_Gray _scale(_Gray image, double scale) {
  if (scale == 1.0) return image;
  final w = max(1, (image.width * scale).round());
  final h = max(1, (image.height * scale).round());
  final src = image.bytes, srcWidth = image.width;
  final out = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    final y0 = y * image.height ~/ h;
    final y1 = max(y0 + 1, (y + 1) * image.height ~/ h);
    for (var x = 0; x < w; x++) {
      final x0 = x * srcWidth ~/ w;
      final x1 = max(x0 + 1, (x + 1) * srcWidth ~/ w);
      var sum = 0;
      for (var sy = y0; sy < y1; sy++) {
        final row = sy * srcWidth;
        for (var sx = x0; sx < x1; sx++) {
          sum += src[row + sx];
        }
      }
      out[y * w + x] = sum ~/ ((x1 - x0) * (y1 - y0));
    }
  }
  return _Gray(out, w, h);
}

/// Averages each pixel with its neighbours up to [radius] away.
_Gray _boxBlur(_Gray image, int radius) {
  final width = image.width, height = image.height;
  // A running sum along each line, so the cost does not grow with [radius].
  Uint8List pass(Uint8List src, int length, int count, int step, int stride) {
    final out = Uint8List(src.length);
    for (var line = 0; line < count; line++) {
      final base = line * stride;
      var sum = 0;
      for (var j = 0; j <= min(radius, length - 1); j++) {
        sum += src[base + j * step];
      }
      for (var i = 0; i < length; i++) {
        final from = max(0, i - radius), to = min(length - 1, i + radius);
        out[base + i * step] = sum ~/ (to - from + 1);
        if (i + radius + 1 < length) sum += src[base + (i + radius + 1) * step];
        if (i - radius >= 0) sum -= src[base + (i - radius) * step];
      }
    }
    return out;
  }

  final horizontal = pass(image.bytes, width, height, 1, width);
  return _Gray(pass(horizontal, height, width, width, 1), width, height);
}

/// Binarizes each pixel against the mean of a square around it, [window]
/// times the shorter side of the image across.
_Gray _localThreshold(_Gray image, double window) {
  final width = image.width, height = image.height, src = image.bytes;
  final half = max(1, (min(width, height) * window).round() ~/ 2);

  // Summed-area table, so each window's sum costs four lookups.
  final stride = width + 1;
  final integral = Uint32List(stride * (height + 1));
  for (var y = 0; y < height; y++) {
    var rowSum = 0;
    for (var x = 0; x < width; x++) {
      rowSum += src[y * width + x];
      integral[(y + 1) * stride + x + 1] =
          integral[y * stride + x + 1] + rowSum;
    }
  }

  final out = Uint8List(width * height);
  for (var y = 0; y < height; y++) {
    final top = max(0, y - half) * stride;
    final bottom = min(height, y + half + 1) * stride;
    final rows = min(height, y + half + 1) - max(0, y - half);
    for (var x = 0; x < width; x++) {
      final left = max(0, x - half), right = min(width, x + half + 1);
      final sum =
          integral[bottom + right] -
          integral[top + right] -
          integral[bottom + left] +
          integral[top + left];
      out[y * width + x] = src[y * width + x] * rows * (right - left) > sum
          ? 255
          : 0;
    }
  }
  return _Gray(out, width, height);
}

/// Binarizes with the threshold that best separates dark from light pixels
/// over the whole image (Otsu's method).
_Gray _otsuThreshold(_Gray image) {
  final src = image.bytes;
  final histogram = List<int>.filled(256, 0);
  for (final v in src) {
    histogram[v]++;
  }
  final total = src.length;
  var sumAll = 0;
  for (var v = 0; v < 256; v++) {
    sumAll += v * histogram[v];
  }

  var threshold = 0;
  var bestVariance = -1.0;
  var countBelow = 0, sumBelow = 0;
  for (var t = 0; t < 256; t++) {
    countBelow += histogram[t];
    sumBelow += t * histogram[t];
    if (countBelow == 0) continue;
    final countAbove = total - countBelow;
    if (countAbove == 0) break;
    final meanBelow = sumBelow / countBelow;
    final meanAbove = (sumAll - sumBelow) / countAbove;
    final variance =
        countBelow *
        countAbove *
        (meanBelow - meanAbove) *
        (meanBelow - meanAbove);
    if (variance > bestVariance) {
      bestVariance = variance;
      threshold = t;
    }
  }

  final out = Uint8List(total);
  for (var i = 0; i < total; i++) {
    out[i] = src[i] > threshold ? 255 : 0;
  }
  return _Gray(out, image.width, image.height);
}

/// Adds a white border, and enlarges small images so each module of the code
/// spans enough pixels.
_Gray _padWithWhite(_Gray image) {
  final width = image.width, height = image.height;
  final border = max(4, max(width, height) ~/ 8);
  final paddedWidth = width + border * 2;
  final paddedHeight = height + border * 2;
  final bytes = Uint8List(paddedWidth * paddedHeight)
    ..fillRange(0, paddedWidth * paddedHeight, 255);
  for (var y = 0; y < height; y++) {
    final dst = (y + border) * paddedWidth + border;
    bytes.setRange(dst, dst + width, image.bytes, y * width);
  }
  final padded = _Gray(bytes, paddedWidth, paddedHeight);

  if (max(paddedWidth, paddedHeight) >= 1000) return padded;
  return _scale(padded, 2);
}
