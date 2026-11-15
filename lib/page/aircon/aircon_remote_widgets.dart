// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/model/aircon_state.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

/// 未配置、加载和错误状态共用的页面框架，提供返回入口。
class AirconRemotePlaceholder extends StatelessWidget {
  const AirconRemotePlaceholder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: const BackButton(),
    ),
    body: child,
  );
}

/// 为顶部操作按钮提供按下缩放反馈。
class AirconPressScaleFeedback extends StatefulWidget {
  /// 包装需要显示按压缩放效果的 [child]。
  const AirconPressScaleFeedback({super.key, required this.child});

  final Widget child;

  /// 创建顶部按钮按压反馈的状态。
  @override
  State<AirconPressScaleFeedback> createState() => _PressScaleFeedbackState();
}

class _PressScaleFeedbackState extends State<AirconPressScaleFeedback> {
  bool _pressed = false;

  /// 监听指针按下、抬起和取消事件，并缩放子控件。
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: pressMotionDuration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// 统一限制卡片宽度，并按顺序播放入场动画。
class AirconCardEntrance extends StatefulWidget {
  /// 用 [index] 计算入场延迟，并约束 [child] 的最大宽度。
  const AirconCardEntrance({
    super.key,
    required this.index,
    required this.child,
  });
  final int index;
  final Widget child;

  /// 创建管理卡片入场动画的状态。
  @override
  State<AirconCardEntrance> createState() => _CardEntranceState();
}

class _CardEntranceState extends State<AirconCardEntrance> {
  bool _started = false;

  /// 首帧绘制后启动入场动画，避免卡片一直停留在初始位置。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _started = true);
    });
  }

  /// 居中并限制卡片宽度；允许动画时按序播放位移动画。
  @override
  Widget build(BuildContext context) {
    // SliverList 会横向撑满可用空间；Center 放松约束后才能限制卡片宽度。
    final card = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
        child: widget.child,
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return card;
    final delay = widget.index * 40;
    final total = delay + 260;
    // 先提交一个可见首帧，再开始错峰入场。
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _started ? 1 : 0),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      child: card,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: child,
      ),
    );
  }
}

/// 温度变化时，根据升降方向滚动切换数值。
class AirconDirectionalTemperature extends StatefulWidget {
  /// 使用 [value]、[style] 和可选的 [suffix] 显示温度。
  const AirconDirectionalTemperature({
    super.key,
    required this.value,
    required this.style,
    this.suffix = "",
  });
  final int value;
  final TextStyle? style;
  final String suffix;

  /// 创建记录温度变化方向的状态。
  @override
  State<AirconDirectionalTemperature> createState() =>
      _DirectionalTemperatureState();
}

class _DirectionalTemperatureState extends State<AirconDirectionalTemperature> {
  late int _oldValue = widget.value;

  /// 保存变化前的温度，用于判断新旧数值的动画方向。
  @override
  void didUpdateWidget(covariant AirconDirectionalTemperature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _oldValue = oldWidget.value;
  }

  /// 根据温度升降方向切换数字，并结合淡入淡出效果。
  @override
  Widget build(BuildContext context) {
    final increasing = widget.value > _oldValue;
    return AnimatedSwitcher(
      duration: stateMotionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final childValue = (child.key as ValueKey<int>).value;
        final incoming = childValue == widget.value;
        final offset = increasing
            ? (incoming ? const Offset(0, 1) : const Offset(0, -1))
            : (incoming ? const Offset(0, -1) : const Offset(0, 1));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: offset, end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        "${widget.value}${widget.suffix}",
        key: ValueKey(widget.value),
        style: widget.style,
      ),
    );
  }
}

/// 模式或风速选项的图标、文字和点击行为。
class AirconSlidingOptionItem {
  /// 创建选项数据；圆钮可显示 [icon] 或 [letter]。
  const AirconSlidingOptionItem({
    this.icon,
    this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData? icon;
  final String? letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// 等分排列选项，并让选中背景在各选项之间滑动。
class AirconSlidingOptionRow extends StatelessWidget {
  /// 排列 [items]；[selectedIndex] 为负时不显示选中背景。
  const AirconSlidingOptionRow({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.enabled,
  });
  final List<AirconSlidingOptionItem> items;
  final int selectedIndex;
  final bool enabled;

  /// 均分可用宽度排列选项，并动画移动选中背景。
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = constraints.maxWidth / items.length;
          return Stack(
            children: [
              if (selectedIndex >= 0)
                AnimatedPositioned(
                  duration: stateMotionDuration,
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * slot + (slot - 54) / 2,
                  top: 0,
                  width: 54,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              for (var i = 0; i < items.length; i++)
                Positioned(
                  left: i * slot,
                  width: slot,
                  top: 0,
                  child: _SlidingOptionCell(
                    item: items[i],
                    selected: i == selectedIndex,
                    enabled: enabled,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 单个选项负责按下反馈和选中状态的颜色过渡。
class _SlidingOptionCell extends StatefulWidget {
  /// 创建单个选项，并根据 [selected] 和 [enabled] 显示对应状态。
  const _SlidingOptionCell({
    required this.item,
    required this.selected,
    required this.enabled,
  });
  final AirconSlidingOptionItem item;
  final bool selected;
  final bool enabled;

  /// 创建记录选项按压状态的对象。
  @override
  State<_SlidingOptionCell> createState() => _SlidingOptionCellState();
}

class _SlidingOptionCellState extends State<_SlidingOptionCell> {
  bool _pressed = false;

  /// 绘制选项图标或字母、标签和按压反馈。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.selected
        ? scheme.onPrimary
        : (widget.enabled ? scheme.onSurfaceVariant : scheme.outline);
    return GestureDetector(
      onTap: widget.enabled ? widget.item.onTap : null,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: pressMotionDuration,
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: stateMotionDuration,
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                  child: widget.item.letter != null
                      ? Text(widget.item.letter!)
                      : TweenAnimationBuilder<Color?>(
                          tween: ColorTween(end: color),
                          duration: stateMotionDuration,
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedColor, _) => Icon(
                            widget.item.icon,
                            size: 24,
                            color: animatedColor,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: stateMotionDuration,
              style: TextStyle(
                fontSize: 12,
                color: widget.selected
                    ? Theme.of(context).colorScheme.primary
                    : scheme.onSurfaceVariant,
                fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 米家风格的圆角卡片，带轻微阴影。
class AirconMiCard extends StatelessWidget {
  /// 包装卡片内容；提供 [onTap] 时启用点击反馈。
  const AirconMiCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// 绘制圆角、阴影和内边距；可点击时添加水波纹。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: onTap == null
            ? content
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  child: content,
                ),
              ),
      ),
    );
  }
}

/// 圆形按钮用主题强调色表示选中状态。
class AirconRoundButton extends StatefulWidget {
  /// 创建圆形操作按钮，颜色和交互由选中及启用状态决定。
  const AirconRoundButton({
    super.key,
    this.icon,
    required this.selected,
    required this.accent,
    this.onAccent,
    required this.onTap,
    this.enabled = true,
    this.size = 56,
  });

  final IconData? icon;

  final bool selected;
  final Color accent;
  final Color? onAccent;
  final VoidCallback onTap;
  final bool enabled;
  final double size;

  /// 创建记录圆钮按压状态的对象。
  @override
  State<AirconRoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<AirconRoundButton> {
  bool _pressed = false;

  /// 根据启用和选中状态绘制圆钮，并提供按压反馈。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = !widget.enabled
        ? scheme.surfaceContainerHighest
        : widget.selected
        ? widget.accent
        : scheme.surfaceContainerHighest;
    final foreground = !widget.enabled
        ? scheme.outline
        : widget.selected
        ? (widget.onAccent ?? scheme.onPrimary)
        : scheme.onSurfaceVariant;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: pressMotionDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: stateMotionDuration,
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(
            widget.icon ?? Icons.circle,
            size: widget.size * 0.5,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// 一行开关，左边一个圆图标、中间文字、右边开关。
class AirconSwitchRow extends StatelessWidget {
  /// 创建带图标和标签的开关行，通过 [onChanged] 处理切换。
  const AirconSwitchRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  /// 绘制功能图标、文字和开关，并在禁用时阻止切换。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: stateMotionDuration,
            curve: Curves.easeOutCubic,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: value
                  ? Theme.of(context).colorScheme.primary
                  : scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: value ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}
