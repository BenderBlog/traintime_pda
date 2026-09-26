// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The corners of the physical display, as queried from the platform.

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:watermeter/repository/logger.dart';

/// Radii of the four corners of the display, in logical pixels.
class DisplayCornerRadii {
  const DisplayCornerRadii({
    this.topLeft = 0,
    this.topRight = 0,
    this.bottomLeft = 0,
    this.bottomRight = 0,
  });

  static const DisplayCornerRadii zero = DisplayCornerRadii();

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  /// The radius content at the bottom edge has to clear.
  double get bottom => math.max(bottomLeft, bottomRight);

  /// The radius content at the leading/trailing edge has to clear.
  double get left => math.max(topLeft, bottomLeft);
  double get right => math.max(topRight, bottomRight);

  @override
  String toString() =>
      "DisplayCornerRadii(topLeft: $topLeft, topRight: $topRight, "
      "bottomLeft: $bottomLeft, bottomRight: $bottomRight)";
}

/// Reader of the rounded corners of the physical display.
///
/// The corner of the screen is not a window inset, so a widget which reaches
/// the edge of the display has no idea that the display is rounded there and
/// gets covered by it. Android knows the radii, so they are queried here and
/// kept, ready for the widgets which are laid out against them.
class DisplayCorner {
  DisplayCorner._();

  static const MethodChannel _channel = MethodChannel("xdyou/display_insets");

  static DisplayCornerRadii _radii = DisplayCornerRadii.zero;

  /// Whether the platform has already been asked again for an answer it did not
  /// have on the first frame.
  static bool _retried = false;

  static DisplayCornerRadii get radii => _radii;

  /// Asks the platform for the radii. Returns the values which are known
  /// afterwards.
  ///
  /// It is called again whenever the window is of a new size, so that the answer
  /// follows the window: the corners of the display stop mattering as soon as the
  /// window no longer covers it (a floating window, a split screen), and the room
  /// they would take is all such a window has.
  static Future<DisplayCornerRadii> refresh() async {
    if (!Platform.isAndroid) {
      return _radii;
    }

    await _query();

    if (!_retried &&
        _radii.bottom == 0 &&
        _radii.left == 0 &&
        _radii.right == 0) {
      /// The window insets are not always there on the very first frame, give
      /// the platform a moment and ask once more.
      _retried = true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _query();
    }

    return _radii;
  }

  static Future<void> _query() async {
    try {
      final result = await _channel.invokeMapMethod<String, num>(
        "getRoundedCornerRadii",
      );
      if (result != null) {
        _radii = DisplayCornerRadii(
          topLeft: (result["topLeft"] ?? 0).toDouble(),
          topRight: (result["topRight"] ?? 0).toDouble(),
          bottomLeft: (result["bottomLeft"] ?? 0).toDouble(),
          bottomRight: (result["bottomRight"] ?? 0).toDouble(),
        );
        log.info("[DisplayCorner] Display corner radii: $_radii");
      }
    } on PlatformException catch (e) {
      log.warning("[DisplayCorner] Unable to read the corner radii: $e");
    } on MissingPluginException {
      log.warning("[DisplayCorner] No platform implementation of the channel");
    }
  }
}
