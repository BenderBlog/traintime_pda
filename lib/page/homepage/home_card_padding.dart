// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

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
    return Builder(
      builder: (sourceContext) => OutlinedButton(
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
            : () {
                ContainerTransformSource.pending = null;
                // 缩略图由首页那边提前抓好（见 ContainerTransformSink），
                // 这里只兜一次：万一还没抓好，也只是这一帧没有背景图。
                // Use the whole BasedSplitView's available width, not the
                // left card column's width (364 in the default two-column UI).
                final splitContext = sourceContext
                    .findAncestorStateOfType<State<BasedSplitView>>()
                    ?.context;
                final splitBox = splitContext?.findRenderObject();
                final availableWidth = splitBox is RenderBox && splitBox.hasSize
                    ? splitBox.size.width
                    : MediaQuery.sizeOf(sourceContext).width;
                if (enableContainerTransform &&
                    availableWidth <= containerTransformSplitBreakpoint) {
                  final sourceBox = sourceContext.findRenderObject();
                  if (sourceBox is RenderBox && sourceBox.hasSize) {
                    // The Builder includes the card's outer four-pixel padding.
                    final bounds = const EdgeInsets.all(
                      4,
                    ).deflateRect(Offset.zero & sourceBox.size);
                    // 用全局坐标：分屏时卡片在左栏、路由在详情栏，
                    // 两边的 Navigator 各有一套坐标，只有全局坐标是对的。
                    // （宽屏本来就不启用这个动效，这里只保证手机上的正确性。）
                    final screen = Offset.zero & MediaQuery.sizeOf(sourceContext);
                    final rect = Rect.fromPoints(
                      sourceBox.localToGlobal(bounds.topLeft),
                      sourceBox.localToGlobal(bounds.bottomRight),
                    ).intersect(screen);
                    if (!rect.isEmpty) {
                      ContainerTransformSource.pending =
                          ContainerTransformSource(
                            fromRect: rect,
                            // 卡片圆角是这个文件里写死的 14；不要从
                            // RoundedSuperellipseBorder 上读，那个 getter
                            // 拿不到真实半径，会退化成直角展开。
                            fromRadius: BorderRadius.circular(14),
                          );
                    }
                  }
                }
                try {
                  // Named navigation resolves the route synchronously, even
                  // when the callback returns a Future that completes on pop.
                  onPressed();
                } finally {
                  ContainerTransformSource.pending = null;
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
      ).padding(all: 4),
    );
  }
}
