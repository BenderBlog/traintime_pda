// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// Reads the IMEI off an aircon sticker too blurry for a QR decoder.
//
// Every sticker encodes the same URL with only the IMEI changed, in the same
// version 7 code at the lowest error correction level: a byte segment for the
// URL, then a numeric one for the 15 digits. Only the mask differs. The logo
// in the middle already uses up about half of the error correction, so a
// little blur is enough to defeat a decoder.
//
// Knowing everything but the IMEI, reading the code comes down to choosing
// the 50 bits of digits that best explain the picture:
//
// 1. Find the finder patterns on a binarized copy, keeping three that are
//    38 modules apart as in this version, and fit where each module is from
//    them and the alignment patterns.
// 2. Sample every module, and undo much of the blur with a small linear
//    filter fitted on the modules whose colour is known in advance.
// 3. Solve the digits from the 50 most reliable of the 210 modules that
//    depend on them, then try flipping one or two of those (ordered
//    statistics decoding), keeping the digits that fit best.
//
// The result is only accepted when the digits fit far better than any other
// candidate, as a wrong IMEI is worse than none.

import 'dart:math';
import 'dart:typed_data';

/// How to look for the code: on the image as is or halved, and the window of
/// the threshold used to find the finder patterns, in pixels.
///
/// Each finds the finder patterns over a different range of sizes: a small
/// window keeps the rings of small or blurry ones, while halving reaches the
/// large ones and is quicker.
typedef AirconTemplatePass = ({bool halve, int window});

/// Passes that together cover the sizes the code takes up in a camera frame.
const List<AirconTemplatePass> airconTemplatePasses = [
  (halve: false, window: 15),
  (halve: true, window: 15),
  (halve: false, window: 31),
];

/// Looks for the sticker in a grayscale image, one byte per pixel, and
/// returns its IMEI, or null if it is not found or not read with confidence.
String? readAirconImeiByTemplate(
  Uint8List pixels,
  int width,
  int height,
  AirconTemplatePass pass,
) {
  final image = _Image(pixels, width, height);
  final searched = pass.halve ? _halve(image) : image;
  if (searched.width < 64 || searched.height < 64) return null;

  var transform = _locate(searched, _binarize(searched, pass.window));
  if (transform == null) return null;
  if (pass.halve) {
    // Pixel i of the halved image is centred between pixels 2i and 2i + 1.
    transform = _Homography(
      Float64List.fromList([2, 0, 0.5, 0, 2, 0.5, 0, 0, 1]),
    ).then(transform);
  }

  final samples = _sampleModules(image, transform);
  if (samples == null) return null;
  final soft = _equalise(samples);
  if (soft == null) return null;
  return _readImei(soft.values, soft.mask);
}

const _prefix = "https://gxkt.juhaolian.cn?imei=";

/// Modules along a side of a version 7 code.
const _n = 45;

/// Centres of the alignment patterns along each axis in a version 7 code.
const _alignments = [6, 22, 38];

/// The logo covers about this square of modules in the middle, and what is
/// sampled there says nothing about the code.
const _logoFrom = 17, _logoTo = 28;

bool _inLogo(int r, int c) =>
    r >= _logoFrom && r < _logoTo && c >= _logoFrom && c < _logoTo;

/// Data codewords in each of the two blocks, and error correction codewords
/// in each.
const _blockData = 78, _blockEc = 20;

/// Where the IMEI digits start in the data: after the byte mode header, the
/// URL and the numeric mode header.
const _imeiStart = 4 + 8 + _prefix.length * 8 + 4 + 10;

/// The digits take 10 bits for each group of three.
const _imeiBits = 50;

/// Margin of modules sampled around the code, for the equalising filter.
const _margin = 2;
const _sampledSide = _n + 2 * _margin;

/// Thresholds for accepting a result, picked from synthetic and real
/// stickers. Unrelated codes agree with the template about half of the time.
const _minTemplateAgreement = 0.85;

/// Real stickers score above 0.9 even when blurry; the best wrong candidate,
/// including on codes made to look like a sticker, below 0.65.
const _minScore = 0.75;
const _minLead = 0.2;

final _template = _Template();

/// The parts of the code that are the same on every sticker.
class _Template {
  _Template() {
    final function = List<bool>.filled(_n * _n, false);
    void set(int r, int c, int colour) {
      function[r * _n + c] = true;
      known[r * _n + c] = colour;
    }

    for (final (top, left) in const [(0, 0), (0, _n - 7), (_n - 7, 0)]) {
      // The finder pattern with the light separator around it.
      for (var i = -1; i <= 7; i++) {
        for (var j = -1; j <= 7; j++) {
          final r = top + i, c = left + j;
          if (r < 0 || r >= _n || c < 0 || c >= _n) continue;
          final ring = max((i - 3).abs(), (j - 3).abs());
          set(r, c, ring == 2 || ring == 4 ? 0 : 1);
        }
      }
    }
    for (var i = 8; i < _n - 8; i++) {
      set(6, i, 1 - i % 2);
      set(i, 6, 1 - i % 2);
    }
    for (final r in _alignments) {
      for (final c in _alignments) {
        if (_cornerAlignment(r, c)) continue;
        for (var i = -2; i <= 2; i++) {
          for (var j = -2; j <= 2; j++) {
            set(r + i, c + j, max(i.abs(), j.abs()) == 1 ? 0 : 1);
          }
        }
      }
    }
    set(_n - 8, 8, 1);
    // Format and version information.
    for (var i = 0; i < 9; i++) {
      function[8 * _n + i] = function[i * _n + 8] = true;
    }
    for (var i = _n - 8; i < _n; i++) {
      function[8 * _n + i] = function[i * _n + 8] = true;
    }
    for (var i = 0; i < 6; i++) {
      for (var j = _n - 11; j < _n - 8; j++) {
        function[i * _n + j] = function[j * _n + i] = true;
      }
    }

    for (var r = 0; r < _n; r++) {
      for (var c = 0; c < _n; c++) {
        if (known[r * _n + c] >= 0 && !_inLogo(r, c)) {
          knownModules.add(r * _n + c);
        }
      }
    }

    // Data modules run in pairs of columns from the right, up and down in
    // turn, skipping the vertical timing pattern.
    var upward = true;
    for (var c = _n - 1; c > 0; c -= 2) {
      if (c == 6) c--;
      for (var k = 0; k < _n; k++) {
        final r = upward ? _n - 1 - k : k;
        for (final cc in [c, c - 1]) {
          if (!function[r * _n + cc]) data.add(r * _n + cc);
        }
      }
      upward = !upward;
    }

    final codewords = _interleave(_dataWithZeroImei());
    bits = Uint8List(data.length);
    for (var i = 0; i < bits.length; i++) {
      bits[i] = (codewords[i >> 3] >> (7 - (i & 7))) & 1;
    }

    // The digit bits all fall in the first block, and change its error
    // correction, which is placed after all the data of both blocks.
    for (var k = 0; k < _imeiBits; k++) {
      final bit = _imeiStart + k;
      dependent.add((bit >> 3) * 2 * 8 + (bit & 7));
      columns.add(1 << k);
    }
    for (var e = 0; e < _blockEc; e++) {
      for (var b = 0; b < 8; b++) {
        dependent.add((2 * _blockData + 2 * e) * 8 + b);
        columns.add(0);
      }
    }
    // The error correction is linear, so each digit bit flips a fixed set
    // of its bits.
    for (var k = 0; k < _imeiBits; k++) {
      final block = Uint8List(_blockData);
      final bit = _imeiStart + k;
      block[bit >> 3] = 0x80 >> (bit & 7);
      final ec = _errorCorrection(block);
      for (var e = 0; e < _blockEc; e++) {
        for (var b = 0; b < 8; b++) {
          if ((ec[e] >> (7 - b)) & 1 == 1) {
            columns[_imeiBits + e * 8 + b] |= 1 << k;
          }
        }
      }
    }
    for (final i in dependent) {
      isDependent[i] = 1;
    }
  }

  /// The colour of each module that is the same in every code: 1 for dark,
  /// 0 for light, -1 for the others.
  final known = Int8List(_n * _n)..fillRange(0, _n * _n, -1);

  /// The modules of [known] that are outside the logo.
  final knownModules = <int>[];

  /// The data modules (row * [_n] + column), in the order bits are placed.
  final data = <int>[];

  /// The bits placed in [data] when the IMEI is all zeros, before masking.
  late final Uint8List bits;

  /// The indices into [data] of the bits that change with the IMEI: the 50
  /// of the digits, then the 160 of the first block's error correction.
  final dependent = <int>[];

  /// For each of [dependent], the digit bits that flip it, bit k standing
  /// for digit bit k.
  final columns = <int>[];

  late final isDependent = Uint8List(data.length);

  static bool _cornerAlignment(int r, int c) =>
      (r == 6 && c == 6) || (r == 6 && c == 38) || (r == 38 && c == 6);

  static Uint8List _dataWithZeroImei() {
    final bits = <int>[];
    void write(int value, int length) {
      for (var i = length - 1; i >= 0; i--) {
        bits.add((value >> i) & 1);
      }
    }

    write(0x4, 4);
    write(_prefix.length, 8);
    for (final unit in _prefix.codeUnits) {
      write(unit, 8);
    }
    write(0x1, 4);
    write(15, 10);
    for (var i = 0; i < 5; i++) {
      write(0, 10);
    }
    write(0, 4);

    final bytes = Uint8List(2 * _blockData);
    for (var i = 0; i < bits.length; i++) {
      bytes[i >> 3] |= bits[i] << (7 - (i & 7));
    }
    for (var i = (bits.length + 7) >> 3, pad = 0; i < bytes.length; i++) {
      bytes[i] = pad++ % 2 == 0 ? 0xEC : 0x11;
    }
    return bytes;
  }

  /// Adds the error correction of both blocks, and interleaves the codewords
  /// as they are placed.
  static Uint8List _interleave(Uint8List data) {
    final first = data.sublist(0, _blockData);
    final second = data.sublist(_blockData);
    final ecs = [_errorCorrection(first), _errorCorrection(second)];
    final out = Uint8List(2 * (_blockData + _blockEc));
    for (var i = 0; i < _blockData; i++) {
      out[2 * i] = first[i];
      out[2 * i + 1] = second[i];
    }
    for (var i = 0; i < _blockEc; i++) {
      out[2 * _blockData + 2 * i] = ecs[0][i];
      out[2 * _blockData + 2 * i + 1] = ecs[1][i];
    }
    return out;
  }
}

/// Reed-Solomon error correction over GF(256), as QR codes use it.
Uint8List _errorCorrection(Uint8List data) {
  final exp = Uint8List(512), log = Uint8List(256);
  for (var i = 0, x = 1; i < 255; i++) {
    exp[i] = exp[i + 255] = x;
    log[x] = i;
    x <<= 1;
    if (x & 0x100 != 0) x ^= 0x11d;
  }
  int multiply(int a, int b) => a == 0 || b == 0 ? 0 : exp[log[a] + log[b]];

  var generator = [1];
  for (var i = 0; i < _blockEc; i++) {
    final next = List<int>.filled(generator.length + 1, 0);
    for (var j = 0; j < generator.length; j++) {
      next[j] ^= generator[j];
      next[j + 1] ^= multiply(generator[j], exp[i]);
    }
    generator = next;
  }

  final remainder = Uint8List(_blockEc);
  for (final byte in data) {
    final factor = byte ^ remainder[0];
    remainder.setRange(0, _blockEc - 1, remainder, 1);
    remainder[_blockEc - 1] = 0;
    for (var j = 0; j < _blockEc; j++) {
      remainder[j] ^= multiply(generator[j + 1], factor);
    }
  }
  return remainder;
}

bool _masked(int mask, int r, int c) => switch (mask) {
  0 => (r + c) % 2 == 0,
  1 => r % 2 == 0,
  2 => c % 3 == 0,
  3 => (r + c) % 3 == 0,
  4 => (r ~/ 2 + c ~/ 3) % 2 == 0,
  5 => (r * c) % 2 + (r * c) % 3 == 0,
  6 => ((r * c) % 2 + (r * c) % 3) % 2 == 0,
  _ => ((r + c) % 2 + (r * c) % 3) % 2 == 0,
};

/// The 15 bits of format information for the lowest error correction level
/// and [mask], most significant first.
int _formatBits(int mask) {
  final data = 1 << 3 | mask;
  var remainder = data << 10;
  for (var i = 14; i >= 10; i--) {
    if ((remainder >> i) & 1 == 1) remainder ^= 0x537 << (i - 10);
  }
  return (data << 10 | remainder) ^ 0x5412;
}

/// Both copies of the format information, from its most significant bit.
const _formatModules = [
  [
    (8, 0), (8, 1), (8, 2), (8, 3), (8, 4), (8, 5), (8, 7), (8, 8), //
    (7, 8), (5, 8), (4, 8), (3, 8), (2, 8), (1, 8), (0, 8),
  ],
  [
    (44, 8), (43, 8), (42, 8), (41, 8), (40, 8), (39, 8), (38, 8), //
    (8, 37), (8, 38), (8, 39), (8, 40), (8, 41), (8, 42), (8, 43), (8, 44),
  ],
];

class _Image {
  const _Image(this.pixels, this.width, this.height);
  final Uint8List pixels;
  final int width;
  final int height;

  /// Interpolates between the pixels around ([x], [y]), or returns null that
  /// far outside the image. A little outside is taken from the edge.
  double? at(double x, double y) {
    if (x < -2 || y < -2 || x >= width + 1 || y >= height + 1) return null;
    x = x.clamp(0.0, width - 1.001);
    y = y.clamp(0.0, height - 1.001);
    final x0 = x.toInt(), y0 = y.toInt();
    final fx = x - x0, fy = y - y0;
    final i = y0 * width + x0;
    final top = pixels[i] + (pixels[i + 1] - pixels[i]) * fx;
    final bottom =
        pixels[i + width] + (pixels[i + width + 1] - pixels[i + width]) * fx;
    return top + (bottom - top) * fy;
  }
}

_Image _halve(_Image image) {
  final width = image.width ~/ 2, height = image.height ~/ 2;
  final src = image.pixels, stride = image.width;
  final out = Uint8List(width * height);
  for (var y = 0; y < height; y++) {
    final row = 2 * y * stride;
    for (var x = 0; x < width; x++) {
      final i = row + 2 * x;
      out[y * width + x] =
          (src[i] + src[i + 1] + src[i + stride] + src[i + stride + 1] + 2) >>
          2;
    }
  }
  return _Image(out, width, height);
}

/// Summed-area table, so the sum over any rectangle costs four lookups.
Uint32List _integral(Uint8List src, int width, int height) {
  final stride = width + 1;
  final out = Uint32List(stride * (height + 1));
  for (var y = 0; y < height; y++) {
    var rowSum = 0;
    for (var x = 0; x < width; x++) {
      rowSum += src[y * width + x];
      out[(y + 1) * stride + x + 1] = out[y * stride + x + 1] + rowSum;
    }
  }
  return out;
}

/// Marks the pixels darker than the mean of a [window] wide square around
/// them with 1, after averaging away single pixels of noise.
Uint8List _binarize(_Image image, int window) {
  final width = image.width, height = image.height, stride = width + 1;

  final raw = _integral(image.pixels, width, height);
  final smooth = Uint8List(width * height);
  for (var y = 0; y < height; y++) {
    final top = max(0, y - 1), bottom = min(height, y + 2);
    for (var x = 0; x < width; x++) {
      final left = max(0, x - 1), right = min(width, x + 2);
      final sum =
          raw[bottom * stride + right] -
          raw[top * stride + right] -
          raw[bottom * stride + left] +
          raw[top * stride + left];
      smooth[y * width + x] = sum ~/ ((bottom - top) * (right - left));
    }
  }

  final integral = _integral(smooth, width, height);
  final half = window ~/ 2;
  final out = Uint8List(width * height);
  for (var y = 0; y < height; y++) {
    final top = max(0, y - half), bottom = min(height, y + half + 1);
    for (var x = 0; x < width; x++) {
      final left = max(0, x - half), right = min(width, x + half + 1);
      final sum =
          integral[bottom * stride + right] -
          integral[top * stride + right] -
          integral[bottom * stride + left] +
          integral[top * stride + left];
      final area = (bottom - top) * (right - left);
      out[y * width + x] = smooth[y * width + x] * area > sum ? 0 : 1;
    }
  }
  return out;
}

/// A projective transform from module coordinates to pixels, row major.
class _Homography {
  const _Homography(this.m);
  final Float64List m;

  (double, double) apply(double x, double y) {
    final w = m[6] * x + m[7] * y + m[8];
    return ((m[0] * x + m[1] * y + m[2]) / w, (m[3] * x + m[4] * y + m[5]) / w);
  }

  /// This transform applied after [other].
  _Homography then(_Homography other) {
    final out = Float64List(9);
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        for (var k = 0; k < 3; k++) {
          out[i * 3 + j] += m[i * 3 + k] * other.m[k * 3 + j];
        }
      }
    }
    return _Homography(out);
  }

  /// The transform taking each of [from] to the matching [to]: affine for
  /// three points, else projective fitted by least squares.
  static _Homography? fit(
    List<(double, double)> from,
    List<(double, double)> to,
  ) {
    if (from.length == 3) {
      final a = [
        for (final (x, y) in from) [x, y, 1.0],
      ];
      final u = _solve(
        [for (final r in a) List.of(r)],
        [for (final p in to) p.$1],
      );
      final v = _solve(
        [for (final r in a) List.of(r)],
        [for (final p in to) p.$2],
      );
      if (u == null || v == null) return null;
      return _Homography(
        Float64List.fromList([u[0], u[1], u[2], v[0], v[1], v[2], 0, 0, 1]),
      );
    }
    final normal = List.generate(8, (_) => List<double>.filled(8, 0));
    final rhs = List<double>.filled(8, 0);
    void add(List<double> row, double value) {
      for (var i = 0; i < 8; i++) {
        for (var j = 0; j < 8; j++) {
          normal[i][j] += row[i] * row[j];
        }
        rhs[i] += row[i] * value;
      }
    }

    for (var i = 0; i < from.length; i++) {
      final (x, y) = from[i];
      final (u, v) = to[i];
      add([x, y, 1, 0, 0, 0, -u * x, -u * y], u);
      add([0, 0, 0, x, y, 1, -v * x, -v * y], v);
    }
    final h = _solve(normal, rhs);
    if (h == null) return null;
    return _Homography(Float64List.fromList([...h, 1]));
  }
}

/// Solves `a x = b` by Gaussian elimination, overwriting both.
List<double>? _solve(List<List<double>> a, List<double> b) {
  final n = b.length;
  for (var col = 0; col < n; col++) {
    var pivot = col;
    for (var r = col + 1; r < n; r++) {
      if (a[r][col].abs() > a[pivot][col].abs()) pivot = r;
    }
    if (a[pivot][col].abs() < 1e-12) return null;
    final row = a[pivot];
    a[pivot] = a[col];
    a[col] = row;
    final value = b[pivot];
    b[pivot] = b[col];
    b[col] = value;
    for (var r = col + 1; r < n; r++) {
      final f = a[r][col] / a[col][col];
      if (f == 0) continue;
      for (var c = col; c < n; c++) {
        a[r][c] -= f * a[col][c];
      }
      b[r] -= f * b[col];
    }
  }
  final x = List<double>.filled(n, 0);
  for (var r = n - 1; r >= 0; r--) {
    var sum = b[r];
    for (var c = r + 1; c < n; c++) {
      sum -= a[r][c] * x[c];
    }
    x[r] = sum / a[r][r];
  }
  return x;
}

class _Finder {
  _Finder(this.x, this.y, this.module);
  double x, y, module;
  int support = 1;
}

/// Whether five runs across a finder pattern are about 1:1:3:1:1, leaving
/// room for the blur.
bool _finderRatio(int a, int b, int c, int d, int e) {
  final module = (a + b + c + d + e) / 7;
  if (module < 1) return false;
  final tolerance = module * 0.7;
  return (a - module).abs() < tolerance &&
      (b - module).abs() < tolerance &&
      (c - 3 * module).abs() < 2.1 * tolerance &&
      (d - module).abs() < tolerance &&
      (e - module).abs() < tolerance;
}

/// Checks across the pattern through ([x], [y]), along a column or a row,
/// and returns where its centre is along that line and its module size.
(double, double)? _crossCheck(
  Uint8List dark,
  int width,
  int height,
  int x,
  int y,
  bool vertical,
) {
  final limit = vertical ? height : width;
  final centre = vertical ? y : x;
  int at(int t) => vertical ? dark[t * width + x] : dark[y * width + t];
  if (at(centre) != 1) return null;

  // Walks over the dark core, the light ring and the dark ring, and returns
  // their lengths and where the light outside starts.
  (int, int, int, int)? walk(int step) {
    final counts = [0, 0, 0];
    var state = 0;
    for (var t = centre; t >= 0 && t < limit; t += step) {
      if (at(t) == (state == 1 ? 0 : 1)) {
        counts[state]++;
        continue;
      }
      if (++state == 3) return (counts[0], counts[1], counts[2], t);
      counts[state]++;
    }
    return null;
  }

  final back = walk(-1), forward = walk(1);
  if (back == null || forward == null) return null;
  final runs = [
    back.$3,
    back.$2,
    back.$1 + forward.$1 - 1,
    forward.$2,
    forward.$3,
  ];
  if (!_finderRatio(runs[0], runs[1], runs[2], runs[3], runs[4])) return null;
  final start = back.$4 + 1 + runs[0] + runs[1];
  return (start + runs[2] / 2, runs.reduce((a, b) => a + b) / 7);
}

/// Finds the finder patterns: runs of about 1:1:3:1:1 along a row, checked
/// along the column and the row through their middle. Each is returned once,
/// those found from the most rows first.
List<_Finder> _findFinders(Uint8List dark, int width, int height) {
  final found = <_Finder>[];
  final starts = Int32List(width + 1), lengths = Int32List(width + 1);
  for (var y = 0; y < height; y++) {
    final row = y * width;
    var count = 0;
    for (var x = 0; x < width;) {
      final colour = dark[row + x];
      var end = x + 1;
      while (end < width && dark[row + end] == colour) {
        end++;
      }
      starts[count] = x;
      lengths[count++] = end - x;
      x = end;
    }
    final firstDark = dark[row] == 1 ? 0 : 1;
    for (var i = firstDark; i + 4 < count; i += 2) {
      if (!_finderRatio(
        lengths[i],
        lengths[i + 1],
        lengths[i + 2],
        lengths[i + 3],
        lengths[i + 4],
      )) {
        continue;
      }
      final cx = starts[i + 2] + lengths[i + 2] / 2;
      final down = _crossCheck(dark, width, height, cx.toInt(), y, true);
      if (down == null) continue;
      final across = _crossCheck(
        dark,
        width,
        height,
        cx.toInt(),
        down.$1.toInt(),
        false,
      );
      if (across == null) continue;
      final rowModule =
          (lengths[i] +
              lengths[i + 1] +
              lengths[i + 2] +
              lengths[i + 3] +
              lengths[i + 4]) /
          7;
      found.add(
        _Finder(across.$1, down.$1, (down.$2 + across.$2 + rowModule) / 3),
      );
    }
  }

  // Merge the sightings of each pattern from neighbouring rows.
  final merged = <_Finder>[];
  for (final f in found) {
    _Finder? same;
    for (final m in merged) {
      if ((m.x / m.support - f.x).abs() < f.module * 2 &&
          (m.y / m.support - f.y).abs() < f.module * 2) {
        same = m;
        break;
      }
    }
    if (same == null) {
      merged.add(f);
    } else {
      same
        ..x += f.x
        ..y += f.y
        ..module += f.module
        ..support += 1;
    }
  }
  for (final m in merged) {
    m
      ..x /= m.support
      ..y /= m.support
      ..module /= m.support;
  }
  merged.sort((a, b) => b.support - a.support);
  return merged;
}

/// Three finders that could be the top left, top right and bottom left ones,
/// the likeliest first.
List<List<_Finder>> _pickTriples(List<_Finder> finders) {
  final top = finders.take(8).toList();
  final triples = <(double, List<_Finder>)>[];
  for (final a in top) {
    for (final b in top) {
      for (final c in top) {
        if (identical(a, b) || identical(a, c) || identical(b, c)) continue;
        // a is the corner, so the side across from it is the longest.
        final ab = sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2));
        final ac = sqrt(pow(c.x - a.x, 2) + pow(c.y - a.y, 2));
        final bc = sqrt(pow(c.x - b.x, 2) + pow(c.y - b.y, 2));
        if (bc < max(ab, ac)) continue;
        // b has to be the top right one: clockwise from c around a.
        final cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
        if (cross <= 0) continue;
        final modules = [a.module, b.module, c.module];
        if (modules.reduce(max) > 1.8 * modules.reduce(min)) continue;
        if (ab / ac < 0.6 || ab / ac > 1.6) continue;
        final cos =
            ((b.x - a.x) * (c.x - a.x) + (b.y - a.y) * (c.y - a.y)) / (ab * ac);
        if (cos.abs() > 0.5) continue;
        // Finder centres are 38 modules apart in a version 7 code.
        final apart = (ab + ac) / 2 / ((a.module + b.module + c.module) / 3);
        if (apart < 25 || apart > 55) continue;
        final cost = log(apart / 38).abs() + cos.abs() + log(ab / ac).abs();
        triples.add((cost, [a, b, c]));
      }
    }
  }
  triples.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final t in triples.take(6)) t.$2];
}

/// Module offsets of the points compared for a finder or alignment pattern,
/// with how dark each should be, centred so a uniform patch scores zero.
final _finderPoints = _patternPoints(4, (ring) => ring == 2 || ring == 4);
final _alignmentPoints = _patternPoints(2, (ring) => ring == 1);

List<(int, int, double)> _patternPoints(int radius, bool Function(int) light) {
  final points = <(int, int, double)>[];
  for (var i = -radius; i <= radius; i++) {
    for (var j = -radius; j <= radius; j++) {
      points.add((j, i, light(max(i.abs(), j.abs())) ? 0 : 1));
    }
  }
  final mean = points.fold(0.0, (sum, p) => sum + p.$3) / points.length;
  return [for (final (x, y, w) in points) (x, y, w - mean)];
}

/// Moves the pattern centred on module ([mx], [my]) by up to [search]
/// modules where it matches the image best. Returns how well it matches,
/// from -1 to 1, and where its centre is in the image.
(double, (double, double))? _refine(
  _Image image,
  _Homography transform,
  List<(int, int, double)> points,
  int mx,
  int my,
  double search,
  double step,
) {
  final steps = (search / step).round();
  var weightNorm = 0.0;
  for (final p in points) {
    weightNorm += p.$3 * p.$3;
  }
  weightNorm = sqrt(weightNorm * points.length);

  double? bestScore;
  var bestDx = 0.0, bestDy = 0.0;
  for (var sy = -steps; sy <= steps; sy++) {
    for (var sx = -steps; sx <= steps; sx++) {
      final dx = sx * step, dy = sy * step;
      var sum = 0.0, squares = 0.0, weighted = 0.0;
      for (var k = 0; k < points.length; k++) {
        final (px, py, w) = points[k];
        final (x, y) = transform.apply(mx + px + 0.5 + dx, my + py + 0.5 + dy);
        final v = image.at(x, y);
        if (v == null) return null;
        sum += v;
        squares += v * v;
        weighted += w * v;
      }
      final mean = sum / points.length;
      final deviation = sqrt(max(0, squares / points.length - mean * mean));
      if (deviation < 1e-6) continue;
      // Dark is low, so a match correlates negatively with the weights.
      final score = -weighted / (deviation * weightNorm);
      if (bestScore == null || score > bestScore) {
        bestScore = score;
        bestDx = dx;
        bestDy = dy;
      }
    }
  }
  if (bestScore == null) return null;
  return (bestScore, transform.apply(mx + 0.5 + bestDx, my + 0.5 + bestDy));
}

/// How well the modules of known colour in the image match the template
/// under [transform], from -1 to 1.
double _fitQuality(_Image image, _Homography transform) {
  final known = _template.known;
  var n = 0;
  var sv = 0.0, sk = 0.0, svv = 0.0, skk = 0.0, svk = 0.0;
  for (final i in _template.knownModules) {
    final (x, y) = transform.apply(i % _n + 0.5, i ~/ _n + 0.5);
    final v = image.at(x, y);
    if (v == null) return -1;
    final k = -known[i].toDouble();
    n++;
    sv += v;
    sk += k;
    svv += v * v;
    skk += k * k;
    svk += v * k;
  }
  final cov = svk - sv * sk / n;
  final vv = svv - sv * sv / n, kk = skk - sk * sk / n;
  return vv <= 0 || kk <= 0 ? -1 : cov / sqrt(vv * kk);
}

/// Works out where the modules of the code are in [image].
_Homography? _locate(_Image image, Uint8List dark) {
  final finders = _findFinders(dark, image.width, image.height);
  if (finders.length < 3) return null;
  const corners = [(3, 3), (41, 3), (3, 41)];
  final cornerCentres = [for (final (x, y) in corners) (x + 0.5, y + 0.5)];

  // The background and the text on the sticker can look like finder patterns
  // too, so keep the three that match the pattern best.
  double? bestScore;
  List<(double, double)>? best;
  for (final triple in _pickTriples(finders)) {
    final transform = _Homography.fit(cornerCentres, [
      for (final f in triple) (f.x, f.y),
    ]);
    if (transform == null) continue;
    var worst = double.infinity;
    final centres = <(double, double)>[];
    for (final (x, y) in corners) {
      final r = _refine(image, transform, _finderPoints, x, y, 1, 0.25);
      if (r == null) break;
      worst = min(worst, r.$1);
      centres.add(r.$2);
    }
    if (centres.length < 3) continue;
    if (bestScore == null || worst > bestScore) {
      bestScore = worst;
      best = centres;
    }
  }
  if (best == null || bestScore! < 0.3) return null;

  final rough = _Homography.fit(cornerCentres, best);
  if (rough == null) return null;
  final from = <(double, double)>[], to = <(double, double)>[];
  for (final (x, y) in corners) {
    final r = _refine(image, rough, _finderPoints, x, y, 0.25, 0.125);
    if (r == null) return null;
    from.add((x + 0.5, y + 0.5));
    to.add(r.$2);
  }

  // The finders alone leave out perspective and the curve of the aircon.
  // The bottom right alignment pattern is the furthest from them, so it is
  // searched widely; with it the others are close to where expected. Data
  // can look like an alignment pattern, so whichever fit matches the known
  // modules best is kept.
  var transform = _Homography.fit(from, to);
  if (transform == null) return null;
  final fits = [transform];
  final corner = _refine(
    image,
    transform,
    _alignmentPoints,
    38,
    38,
    1.5,
    0.125,
  );
  if (corner != null && corner.$1 > 0.5) {
    from.add((38.5, 38.5));
    to.add(corner.$2);
    final fit = _Homography.fit(from, to);
    if (fit != null) fits.add(transform = fit);
  }
  final before = from.length;
  for (final (x, y) in const [(22, 6), (6, 22), (38, 22), (22, 38)]) {
    final r = _refine(image, transform, _alignmentPoints, x, y, 0.5, 0.125);
    if (r != null && r.$1 > 0.4) {
      from.add((x + 0.5, y + 0.5));
      to.add(r.$2);
    }
  }
  if (from.length > before && from.length >= 4) {
    final fit = _Homography.fit(from, to);
    if (fit != null) fits.add(fit);
  }

  _Homography? chosen;
  var chosenQuality = double.negativeInfinity;
  for (final fit in fits) {
    final quality = _fitQuality(image, fit);
    if (quality > chosenQuality) {
      chosen = fit;
      chosenQuality = quality;
    }
  }
  return chosen;
}

/// Samples the middle of every module, and [_margin] modules around the
/// code, averaging a few points against the dots printed on the sticker.
Float64List? _sampleModules(_Image image, _Homography transform) {
  const offsets = [-0.2, 0.0, 0.2];
  final out = Float64List(_sampledSide * _sampledSide);
  for (var r = -_margin; r < _n + _margin; r++) {
    for (var c = -_margin; c < _n + _margin; c++) {
      var sum = 0.0;
      for (final dy in offsets) {
        for (final dx in offsets) {
          final (x, y) = transform.apply(c + 0.5 + dx, r + 0.5 + dy);
          final v = image.at(x, y);
          if (v == null) return null;
          sum += v;
        }
      }
      out[(r + _margin) * _sampledSide + c + _margin] = sum / 9;
    }
  }
  return out;
}

/// Turns the samples into how dark each module is, positive for dark and
/// about 1 when certain, 0 in the logo. Also returns the mask of the code.
///
/// Blur mixes each module with its neighbours. A 5 by 5 filter fitted on
/// the modules whose colour is known (the patterns, and once the mask is
/// known, all data that does not depend on the IMEI) separates them again.
({Float64List values, int mask})? _equalise(Float64List samples) {
  final template = _template;
  double sampleAt(int r, int c) =>
      samples[(r + _margin) * _sampledSide + c + _margin];

  // Read the mask from the format information before the filter, which
  // needs to know it.
  var dark = 0.0, light = 0.0, darkCount = 0, lightCount = 0;
  for (final i in template.knownModules) {
    final v = sampleAt(i ~/ _n, i % _n);
    if (template.known[i] == 1) {
      dark += v;
      darkCount++;
    } else {
      light += v;
      lightCount++;
    }
  }
  dark /= darkCount;
  light /= lightCount;
  if (light - dark < 5) return null;
  double plain(int r, int c) =>
      (((dark + light) / 2 - sampleAt(r, c)) / (light - dark) * 2).clamp(
        -1.5,
        1.5,
      );

  var mask = 0;
  var maskScore = double.negativeInfinity;
  for (var m = 0; m < 8; m++) {
    final bits = _formatBits(m);
    var score = 0.0;
    for (final copy in _formatModules) {
      for (var k = 0; k < 15; k++) {
        final (r, c) = copy[k];
        score += plain(r, c) * ((bits >> (14 - k)) & 1 == 1 ? 1 : -1);
      }
    }
    if (score > maskScore) {
      maskScore = score;
      mask = m;
    }
  }

  // Modules of known colour, with 1 for dark and -1 for light.
  final pilots = <(int, double)>[];
  for (final i in template.knownModules) {
    pilots.add((i, template.known[i] == 1 ? 1 : -1));
  }
  for (var k = 0; k < template.data.length; k++) {
    final i = template.data[k];
    if (template.isDependent[k] == 1 || _inLogo(i ~/ _n, i % _n)) continue;
    final bit = template.bits[k] ^ (_masked(mask, i ~/ _n, i % _n) ? 1 : 0);
    pilots.add((i, bit == 1 ? 1 : -1));
  }

  var mean = 0.0, squares = 0.0;
  for (final v in samples) {
    mean += v;
    squares += v * v;
  }
  mean /= samples.length;
  final deviation = sqrt(max(1e-9, squares / samples.length - mean * mean));
  final z = Float64List.fromList([
    for (final v in samples) (v - mean) / deviation,
  ]);

  const side = 5, features = side * side + 1;
  void featuresOf(int i, Float64List out) {
    final r = i ~/ _n, c = i % _n;
    var k = 0;
    for (var dr = -2; dr <= 2; dr++) {
      final row = (r + dr + _margin) * _sampledSide + _margin + c;
      for (var dc = -2; dc <= 2; dc++) {
        out[k++] = z[row + dc];
      }
    }
    out[k] = 1;
  }

  final normal = List.generate(
    features,
    (_) => List<double>.filled(features, 0),
  );
  final rhs = List<double>.filled(features, 0);
  final f = Float64List(features);
  for (final (i, target) in pilots) {
    featuresOf(i, f);
    for (var a = 0; a < features; a++) {
      final fa = f[a];
      final row = normal[a];
      for (var b = a; b < features; b++) {
        row[b] += fa * f[b];
      }
      rhs[a] += fa * target;
    }
  }
  for (var a = 0; a < features; a++) {
    normal[a][a] += 1e-3;
    for (var b = 0; b < a; b++) {
      normal[a][b] = normal[b][a];
    }
  }
  final weights = _solve(normal, rhs);
  if (weights == null) return null;

  final values = Float64List(_n * _n);
  for (var i = 0; i < _n * _n; i++) {
    if (_inLogo(i ~/ _n, i % _n)) continue;
    featuresOf(i, f);
    var v = 0.0;
    for (var a = 0; a < features; a++) {
      v += f[a] * weights[a];
    }
    values[i] = v.clamp(-1.5, 1.5);
  }
  return (values: values, mask: mask);
}

int _parity(int x) {
  x ^= x >> 32;
  x ^= x >> 16;
  x ^= x >> 8;
  x ^= x >> 4;
  x ^= x >> 2;
  x ^= x >> 1;
  return x & 1;
}

/// The 15 digits encoded by [bits], or null if they are not an IMEI.
String? _digits(int bits) {
  final digits = StringBuffer();
  var luhn = 0;
  for (var g = 0; g < 5; g++) {
    var value = 0;
    for (var i = 0; i < 10; i++) {
      value = value << 1 | ((bits >> (10 * g + i)) & 1);
    }
    if (value > 999) return null;
    final group = value.toString().padLeft(3, "0");
    digits.write(group);
    for (var i = 0; i < 3; i++) {
      // The Luhn check doubles every second digit from the right, starting
      // with the one before the check digit.
      var d = group.codeUnitAt(i) - 0x30;
      if ((14 - (3 * g + i)) % 2 == 1) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      luhn += d;
    }
  }
  return luhn % 10 == 0 ? digits.toString() : null;
}

/// Reads the IMEI from how dark each module is, if the code is the sticker
/// and the digits fit clearly better than any others.
String? _readImei(Float64List values, int mask) {
  final template = _template;
  final dependentCount = template.dependent.length;

  // Everything but the digits is known; a code that does not match is not
  // the sticker.
  var agree = 0.0, total = 0.0;
  for (var k = 0; k < template.data.length; k++) {
    if (template.isDependent[k] == 1) continue;
    final i = template.data[k];
    final v = values[i];
    if (v == 0) continue;
    final dark = template.bits[k] ^ (_masked(mask, i ~/ _n, i % _n) ? 1 : 0);
    total += v.abs();
    if ((v > 0) == (dark == 1)) agree += v.abs();
  }
  if (total == 0 || agree / total < _minTemplateAgreement) return null;

  // How much each bit that depends on the IMEI looks like a 1, after the
  // mask, relative to the bit with an IMEI of zeros.
  final evidence = Float64List(dependentCount);
  final base = Uint8List(dependentCount);
  final observed = Uint8List(dependentCount);
  var absoluteSum = 0.0;
  for (var p = 0; p < dependentCount; p++) {
    final k = template.dependent[p];
    final i = template.data[k];
    final v = values[i];
    evidence[p] = _masked(mask, i ~/ _n, i % _n) ? -v : v;
    base[p] = template.bits[k];
    observed[p] = (evidence[p] > 0 ? 1 : 0) ^ base[p];
    absoluteSum += v.abs();
  }
  if (absoluteSum == 0) return null;

  // Solve the digits from the most reliable bits that determine them.
  final order = List<int>.generate(dependentCount, (p) => p)
    ..sort((a, b) => evidence[b].abs().compareTo(evidence[a].abs()));
  // Kept reduced: each vector has its pivot bit and no other pivot's bit.
  // Alongside, which of the chosen bits it is the sum of.
  final pivots = <int, (int, int)>{};
  final chosen = <int>[];
  for (final p in order) {
    var vector = template.columns[p];
    var sources = 1 << chosen.length;
    for (final MapEntry(key: bit, value: (v, s)) in pivots.entries) {
      if ((vector >> bit) & 1 == 1) {
        vector ^= v;
        sources ^= s;
      }
    }
    if (vector == 0) continue;
    final bit = vector.bitLength - 1;
    for (final key in pivots.keys.toList()) {
      final (v, s) = pivots[key]!;
      if ((v >> bit) & 1 == 1) pivots[key] = (v ^ vector, s ^ sources);
    }
    pivots[bit] = (vector, sources);
    chosen.add(p);
    if (chosen.length == _imeiBits) break;
  }
  if (chosen.length < _imeiBits) return null;

  // Each pivot is now a single digit bit; flipping chosen bit j flips the
  // digit bits whose sources include it.
  final flips = List<int>.filled(_imeiBits, 0);
  for (final MapEntry(key: bit, value: (_, sources)) in pivots.entries) {
    for (var j = 0; j < _imeiBits; j++) {
      if ((sources >> j) & 1 == 1) flips[j] |= 1 << bit;
    }
  }
  var solved = 0;
  for (var j = 0; j < _imeiBits; j++) {
    if (observed[chosen[j]] == 1) solved ^= flips[j];
  }

  double score(int bits) {
    var sum = 0.0;
    for (var p = 0; p < dependentCount; p++) {
      final bit = _parity(template.columns[p] & bits) ^ base[p];
      sum += bit == 1 ? evidence[p] : -evidence[p];
    }
    return sum / absoluteSum;
  }

  String? best;
  var bestScore = double.negativeInfinity,
      secondScore = double.negativeInfinity;
  void consider(int bits) {
    final digits = _digits(bits);
    if (digits == null) return;
    final s = score(bits);
    if (s > bestScore) {
      secondScore = bestScore;
      bestScore = s;
      best = digits;
    } else if (s > secondScore) {
      secondScore = s;
    }
  }

  consider(solved);
  for (var a = 0; a < _imeiBits; a++) {
    consider(solved ^ flips[a]);
    for (var b = a + 1; b < _imeiBits; b++) {
      consider(solved ^ flips[a] ^ flips[b]);
    }
  }

  if (bestScore < _minScore || bestScore - secondScore < _minLead) return null;
  return best;
}
