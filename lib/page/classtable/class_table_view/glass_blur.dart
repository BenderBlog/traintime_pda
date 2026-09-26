// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Frosted glass: a backdrop blur for the controls that sit over the table.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// Tells every [GlassBlur] below it whether it may blur at all.
///
/// The settings page's preview uses this to switch the blur off: it is a small static sample where
/// the blur is barely visible, while a whole tableful of backdrop filters makes the page stutter
/// while it scrolls.
class GlassBlurScope extends InheritedWidget {
  const GlassBlurScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  /// Whether the controls in this subtree may blur their backgrounds.
  final bool enabled;

  /// Whether a [GlassBlur] here may blur, taking the scopes above it into account.
  static bool allowsBlur(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassBlurScope>()?.enabled ??
      true;

  @override
  bool updateShouldNotify(GlassBlurScope oldWidget) =>
      oldWidget.enabled != enabled;
}

/// Blurs whatever is painted behind it, clipped to its own bounds.
///
/// This is what gives a control its frosted background: the wallpaper and the table behind the
/// control stay sharp, only the control's own background is blurred.
///
/// The filter is always clipped, either by the caller's own [ClipRRect] or by [borderRadius], because
/// a backdrop filter reads back everything painted before it within its clip: with a clip that is the
/// control's own rectangle rather than the screen, the read stays small.
///
/// Set [grouped] where many filters share a backdrop and none of them overlap — the class cards, for
/// one. Under a [BackdropGroup] the engine then performs the blur once for all of them instead of
/// once per card, which is what makes a table full of frosted cards affordable. Filters that overlap
/// something else must not share the key, so the panels floating over the cards use their own.
class GlassBlur extends StatelessWidget {
  const GlassBlur({
    super.key,
    this.borderRadius,
    this.sigma = glassBlurSigma,
    this.grouped = false,
    this.child,
  });

  /// The shape the blur is clipped to. Null leaves the clipping to an ancestor.
  final BorderRadiusGeometry? borderRadius;

  /// Blur strength in logical pixels. Zero or less leaves the backdrop untouched.
  final double sigma;

  /// Whether to share the blur with the other grouped filters in this [BackdropGroup].
  final bool grouped;

  /// Painted over the blurred backdrop, normally the control's translucent tint.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    /// Turned off in the settings, a control keeps its translucent tint and only loses the blur. The
    /// same goes inside a scope that asks for no blur at all.
    if (!GlassStyleConfig.enabled ||
        !GlassBlurScope.allowsBlur(context) ||
        sigma <= 0) {
      return child ?? const SizedBox.shrink();
    }

    final ui.ImageFilter filter = ui.ImageFilter.blur(
      sigmaX: sigma,
      sigmaY: sigma,
      tileMode: ui.TileMode.clamp,
    );
    final Widget blurred = grouped
        ? BackdropFilter.grouped(filter: filter, child: child)
        : BackdropFilter(filter: filter, child: child);

    if (borderRadius == null) {
      return blurred;
    }
    return ClipRRect(borderRadius: borderRadius!, child: blurred);
  }
}
