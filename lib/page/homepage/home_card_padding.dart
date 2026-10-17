// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

import 'package:based_split_view/based_split_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/public_widget/container_transform.dart';
import 'package:styled_widget/styled_widget.dart';

enum HomeCardType { plain, filled, warning }

extension HomeCardPadding on Widget {
  Widget withHomeCardStyle(
    BuildContext context, {
    HomeCardType type = HomeCardType.plain,
    FutureOr<void> Function()? onPressed,
    bool enableContainerTransform = false,
  }) {
    final cardShape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(14),
    );
    final boundaryKey = GlobalKey();
    var capturing = false;
    return Builder(
      builder: (sourceContext) => RepaintBoundary(
        key: boundaryKey,
        child: OutlinedButton(
          //elevation: 0,
          clipBehavior: Clip.antiAlias,
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(cardShape),
            iconColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.primary,
            ),
            iconSize: WidgetStateProperty.all(20),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              final colorScheme = Theme.of(context).colorScheme;
              if (type == HomeCardType.warning) {
                return colorScheme.errorContainer;
              }
              if (type == HomeCardType.filled) {
                return colorScheme.surfaceContainerHigh;
              }
              return colorScheme.surfaceContainerLow;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              final colorScheme = Theme.of(context).colorScheme;
              if (type == HomeCardType.warning) {
                return colorScheme.onErrorContainer;
              }
              if (type == HomeCardType.filled) {
                return colorScheme.onSurfaceVariant;
              }
              return colorScheme.onSurfaceVariant;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              final colorScheme = Theme.of(context).colorScheme;
              if (type == HomeCardType.warning) {
                return BorderSide(color: colorScheme.error);
              }
              if (type == HomeCardType.filled) {
                return BorderSide.none;
              }
              final hoverColor = colorScheme.primary.withValues(alpha: 0.6);
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused) ||
                  states.contains(WidgetState.pressed)) {
                return BorderSide(color: hoverColor);
              }
              return BorderSide(color: colorScheme.surfaceContainerHighest);
            }),
          ),
          onPressed: onPressed == null
              ? null
              : () async {
                  if (capturing) return;
                  capturing = true;
                  ContainerTransformSource.pending?.dispose();
                  ContainerTransformSource.pending = null;
                  ContainerTransformSource? source;
                  try {
                    // Use the whole BasedSplitView's available width, not the
                    // left card column's width (364 in the default two-column UI).
                    final splitContext = sourceContext
                        .findAncestorStateOfType<State<BasedSplitView>>()
                        ?.context;
                    final splitBox = splitContext?.findRenderObject();
                    final availableWidth =
                        splitBox is RenderBox && splitBox.hasSize
                        ? splitBox.size.width
                        : MediaQuery.sizeOf(sourceContext).width;
                    if (enableContainerTransform &&
                        availableWidth <= containerTransformSplitBreakpoint) {
                      final boundary = boundaryKey.currentContext
                          ?.findRenderObject();
                      if (boundary is RenderRepaintBoundary &&
                          boundary.hasSize) {
                        final screen =
                            Offset.zero & MediaQuery.sizeOf(sourceContext);
                        final rect = Rect.fromPoints(
                          boundary.localToGlobal(Offset.zero),
                          boundary.localToGlobal(
                            boundary.size.bottomRight(Offset.zero),
                          ),
                        ).intersect(screen);
                        if (!rect.isEmpty) {
                          ui.Image? snapshot;
                          final ratio = MediaQuery.devicePixelRatioOf(
                            sourceContext,
                          ).clamp(0.0, 2.0);
                          try {
                            // A press can invalidate the button's ink painting.
                            if (boundary.debugNeedsPaint) {
                              await WidgetsBinding.instance.endOfFrame;
                            }
                            if (!sourceContext.mounted) return;
                            if (boundary.attached) {
                              snapshot = await boundary.toImage(
                                pixelRatio: ratio,
                              );
                            }
                          } catch (_) {
                            // Keep the original transition if capture fails.
                          }
                          if (!sourceContext.mounted) {
                            snapshot?.dispose();
                            return;
                          }
                          source = ContainerTransformSource(
                            fromRect: rect,
                            // RoundedSuperellipseBorder does not expose the
                            // actual radius; the card uses a fixed radius of 14.
                            fromRadius: BorderRadius.circular(14),
                            snapshot: snapshot,
                          );
                        }
                      }
                    }
                    ContainerTransformSource.pending = source;
                    // Named navigation resolves synchronously; the returned
                    // Future may last until pop, so do not await it here.
                    onPressed();
                  } finally {
                    ContainerTransformSource.pending = null;
                    source?.dispose();
                    capturing = false;
                  }
                },
          child: DefaultTextStyle(
            style: TextStyle(
              color: type == HomeCardType.warning
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: this,
          ),
        ),
      ).padding(all: 4),
    );
  }
}
