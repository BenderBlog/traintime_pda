// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:image/image.dart' as img;
import 'package:pda_network/src/utils/ids_slider_solver.dart';
import 'package:test/test.dart';

void main() {
  test('matches the original slider offset on a shifted image', () {
    final piece = img.Image(width: 100, height: 100);
    final puzzle = img.Image(width: 180, height: 100);
    for (var y = 0; y < 100; y++) {
      for (var x = 0; x < 180; x++) {
        final value = (x * 11 + y * 23) % 256;
        puzzle.setPixelRgba(x, y, value, value, value, 255);
      }
      for (var x = 0; x < 100; x++) {
        final value = (x * 37 + y * 19 + x * y * 7) % 256;
        piece.setPixelRgba(x, y, value, value, value, 255);
        puzzle.setPixelRgba(x + 25, y, value, value, value, 255);
      }
    }

    expect(
      IdsSliderAlgorithms.solveOffset(
        img.encodePng(puzzle),
        img.encodePng(piece),
      ),
      closeTo(25 / 180, 0.000001),
    );
  });

  test('keeps the original skewed track shape and point timing', () {
    final tracks = IdsSliderAlgorithms.generateTracks(100);

    expect(tracks.length, inInclusiveRange(12, 16));
    expect(tracks.first.toJson(), {'a': 0, 'b': 0, 'c': 0});
    expect(tracks.last.a, 100);
    expect(
      tracks.skip(1).every((point) => point.c >= 300 && point.c <= 500),
      isTrue,
    );
    expect(tracks.every((point) => point.b.abs() <= 10), isTrue);
    expect(jsonEncode(tracks.last), contains('"a":100'));
  });
}
