// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

/// An expandable group of segmented setting surfaces.
///
/// Every surface uses [innerRadius] and the whole visible group is clipped
/// with [outerRadius], so the outer corners always follow the visible bottom
/// edge while expanding or collapsing, instead of being animated separately.
class SettingExpandableSection extends StatefulWidget {
  const SettingExpandableSection({
    super.key,
    required this.header,
    required this.children,
    this.onChildTap,
    this.headerPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.childPadding = EdgeInsets.zero,
    this.gap = 2,
    this.outerRadius = 24,
    this.innerRadius = 4,
    this.color,
  });

  final Widget header;
  final List<Widget> children;
  final ValueChanged<int>? onChildTap;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry childPadding;
  final double gap;
  final double outerRadius;
  final double innerRadius;
  final Color? color;

  @override
  State<SettingExpandableSection> createState() =>
      _SettingExpandableSectionState();
}

class _SettingExpandableSectionState extends State<SettingExpandableSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Durations.medium4,
    reverseDuration: Durations.medium2,
  )..addStatusListener(_onStatusChanged);

  // 使用不回弹的曲线，避免收起时越过 0 后子项重新出现。
  late final CurvedAnimation _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubicEmphasized,
    reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
  );

  void _onStatusChanged(AnimationStatus status) {
    // 收起完成后移除子项，避免折叠状态下仍然布局全部子项。
    if (status.isDismissed && mounted) setState(() {});
  }

  void _toggle() {
    M3EHapticFeedback.light.apply();
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(ColorScheme colors) {
    final pillColor = colors.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        return Container(
          width: 32,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pillColor.withValues(alpha: pillColor.a * progress),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Transform.rotate(angle: progress * math.pi, child: child),
        );
      },
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: colors.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final surfaceColor = widget.color ?? colors.surfaceContainer;
    final surfaceShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(widget.innerRadius),
    );
    final showChildren = _expanded || !_controller.isDismissed;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.outerRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: surfaceColor,
            shape: surfaceShape,
            clipBehavior: Clip.antiAlias,
            child: Semantics(
              expanded: _expanded,
              child: InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: widget.headerPadding,
                  child: Row(
                    children: [
                      Expanded(child: widget.header),
                      const SizedBox(width: 8),
                      _buildIndicator(colors),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showChildren)
            SizeTransition(
              sizeFactor: _animation,
              alignment: Alignment.topCenter,
              // 子项只在展开状态变化时构建，动画过程中复用绘制结果。
              child: RepaintBoundary(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < widget.children.length; i++) ...[
                      SizedBox(height: widget.gap),
                      Material(
                        color: surfaceColor,
                        shape: surfaceShape,
                        clipBehavior: Clip.antiAlias,
                        child: widget.onChildTap == null
                            ? Padding(
                                padding: widget.childPadding,
                                child: widget.children[i],
                              )
                            : InkWell(
                                onTap: () => widget.onChildTap!(i),
                                child: Padding(
                                  padding: widget.childPadding,
                                  child: widget.children[i],
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
