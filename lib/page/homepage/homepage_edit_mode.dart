// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

/// 编辑态下可长按拖拽、相互交换位置的卡片包装。
///
/// 每张卡片同时是 [LongPressDraggable]（可被拖走）和 [DragTarget]
/// （可接收别人的拖拽），松手时触发 [onSwap] 交换两个 id 的位置。
class DraggableCard extends StatelessWidget {
  final String id;
  final Widget child;
  final void Function(String draggedId, String targetId) onSwap;
  final double feedbackWidth;
  final double feedbackHeight;

  const DraggableCard({
    super.key,
    required this.id,
    required this.child,
    required this.onSwap,
    this.feedbackWidth = 80,
    this.feedbackHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != id,
      onAcceptWithDetails: (details) => onSwap(details.data, id),
      builder: (context, candidateData, _) {
        final isHovering = candidateData.isNotEmpty;
        return LongPressDraggable<String>(
          data: id,
          // 手指下跟随的反馈副本；Material 包裹保证文字样式不丢失
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: feedbackWidth,
              height: feedbackHeight,
              child: Opacity(opacity: 0.8, child: child),
            ),
          ),
          // 原位留下的半透明占位，保持布局不塌陷
          childWhenDragging: Opacity(opacity: 0.15, child: child),
          // 正常态 + 悬停高亮边框
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: isHovering
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
