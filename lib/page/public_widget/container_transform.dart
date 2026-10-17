// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

import 'package:material_ui/material_ui.dart';

const containerTransformForwardDuration = Duration(milliseconds: 420);
const containerTransformReverseDuration = Duration(milliseconds: 320);

/// 没有来源卡片时用的短过渡：不然页面会是"闪现"出来的。
const containerTransformPlainDuration = Duration(milliseconds: 220);

// HomePage uses BasedSplitView's defaults: left minimum 364, divider 1,
// right minimum 364. It switches to two columns only above their sum.
const containerTransformSplitBreakpoint = 364.0 + 1.0 + 364.0;

/// One-shot handoff from a home card to Routes.resolveRoute.
/// Clear after the navigation callback too, in case navigation was skipped.
class ContainerTransformSource {
  ContainerTransformSource({
    required this.fromRect,
    required this.fromRadius,
    ui.Image? snapshot,
  }) : _snapshot = snapshot;

  final Rect fromRect;
  final BorderRadius fromRadius;
  ui.Image? _snapshot;
  static ContainerTransformSource? pending;
  static ContainerTransformSource? _consumed;

  static ContainerTransformSource? consume() {
    final source = pending;
    pending = null;
    _consumed?.dispose();
    _consumed = source;
    return source;
  }

  // Routes forwards only the rect and radius. Transfer image ownership here
  // while that synchronous route resolution is still in progress.
  static ui.Image? _takeSnapshot(Rect? fromRect) {
    final source = _consumed;
    _consumed = null;
    if (source == null) return null;
    if (!identical(source.fromRect, fromRect)) {
      source.dispose();
      return null;
    }
    final snapshot = source._snapshot;
    source._snapshot = null;
    return snapshot;
  }

  /// Release an image if navigation did not hand it to a transform route.
  void dispose() {
    if (identical(_consumed, this)) _consumed = null;
    _snapshot?.dispose();
    _snapshot = null;
  }
}

/// 打开页面时下面那层（首页）缩一点、带点圆角，也就是 iOS / HyperOS 那种"下沉"。
///
/// 首页在另一个 Navigator 里，路由碰不到它，所以用一个全局值让它自己动：
/// 路由的转场驱动这个值，首页用 [ContainerTransformSink] 监听。
final ValueNotifier<double> containerTransformSink = ValueNotifier<double>(0);

/// 包住首页的那个 Sink 自己的 key：BasedSplitView 要求 leftWidget 必须带 key。
final GlobalKey containerTransformSinkKey = GlobalKey();

/// 包在首页外面，跟着 [containerTransformSink] 缩放。
class ContainerTransformSink extends StatelessWidget {
  const ContainerTransformSink({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: containerTransformSink,
      child: child,
      builder: (context, value, child) {
        if (value <= 0.001) return child!;
        return ColoredBox(
          // 缩下去之后后面不能是黑的：先铺一层 App 自己的底色。
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Transform.scale(
            scale: 1 - 0.05 * value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16 * value),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// 把路由动画值同步给 [containerTransformSink]，页面离开时归零。
class _SinkDriver extends StatefulWidget {
  const _SinkDriver({required this.animation});

  final Animation<double> animation;

  @override
  State<_SinkDriver> createState() => _SinkDriverState();
}

class _SinkDriverState extends State<_SinkDriver> {
  void _sync() => containerTransformSink.value = widget.animation.value;

  /// 帧后再通知：initState / dispose 期间同步改这个值，
  /// 会让首页那棵兄弟子树在构建或拆卸过程中被要求 setState，debug 下会断言。
  void _syncLater() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_sync);
    _syncLater();
  }

  @override
  void dispose() {
    widget.animation.removeListener(_sync);
    containerTransformSink.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 直线插值，不要走弧线。
///
/// 之前这里做过"中心弧线"，结果长条形的卡片打开时会明显左右抽动
/// （卡片越长横向偏移越大）。参考里说的非线性是**时间曲线**，不是空间路径。
class ContainerTransformRectTween extends RectTween {
  ContainerTransformRectTween({super.begin, super.end});
}

/// 动画期间用「目标的快照」代替真实页面绘制。
///
/// 真实页面始终留在树里（照常构建、布局、保持存活），只是当快照可用时
/// 用 `Opacity(0)` 让它**不参与绘制**（Flutter 在 alpha 为 0 时会直接跳过绘制），
/// 画面上由那张位图顶上。落地时把快照撤掉，露出来的就是已经建好的真实页面 ——
/// 不重建、不闪、也不需要课表做任何配合。
class _ContainerTransformSurface extends StatefulWidget {
  const _ContainerTransformSurface({
    required this.child,
    required this.showSnapshot,
  });

  final Widget child;
  final bool showSnapshot;

  @override
  State<_ContainerTransformSurface> createState() =>
      _ContainerTransformSurfaceState();
}

class _ContainerTransformSurfaceState
    extends State<_ContainerTransformSurface> {
  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _snapshot;

  @override
  void initState() {
    super.initState();
    // 等真实页面画完第一帧再抓，不然抓到的可能是空的。
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    if (!mounted) return;
    final boundary = _boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return;
    try {
      final ratio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0);
      final image = await boundary.toImage(pixelRatio: ratio);
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _snapshot?.dispose();
        _snapshot = image;
      });
    } catch (_) {
      // 抓不到就继续画真实页面，最多是回到原来的表现。
    }
  }

  @override
  void dispose() {
    _snapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final useSnapshot = widget.showSnapshot && snapshot != null;
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: useSnapshot ? 0 : 1,
          child: RepaintBoundary(key: _boundaryKey, child: widget.child),
        ),
        if (useSnapshot)
          // 收尾这段 120ms 的淡出很关键：快照是"第一帧那一刻"的画面，
          // 而真实页面在这 420ms 里可能刚把异步内容（比如课表壁纸）画出来。
          // 直接硬切会看到那些内容突然出现，淡出就看不出来了。
          AnimatedOpacity(
            opacity: widget.showSnapshot ? 1 : 0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: RawImage(image: snapshot, fit: BoxFit.contain),
          ),
      ],
    );
  }
}

/// 「正在长大的窗口」：从控件的位置长到整屏，带圆角。
///
/// 页面本身尺寸恒定，只有这个窗口在动 —— 每帧只是换一个裁切形状，
/// 不会引起子树重新布局。
class _TransformWindowClipper extends CustomClipper<Path> {
  const _TransformWindowClipper({required this.rect, required this.radius});

  final Rect rect;
  final BorderRadius radius;

  @override
  Path getClip(Size size) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, radius.topLeft));

  @override
  bool shouldReclip(_TransformWindowClipper oldClipper) =>
      oldClipper.rect != rect || oldClipper.radius != radius;
}

/// The route owns the card image after the synchronous source handoff.
class _ContainerTransformRoute<T> extends PageRouteBuilder<T> {
  _ContainerTransformRoute({
    required this.cardSnapshot,
    required super.pageBuilder,
    required super.transitionsBuilder,
    required super.transitionDuration,
    required super.reverseTransitionDuration,
    super.settings,
  }) : super(opaque: false, barrierColor: null);

  final ui.Image? cardSnapshot;

  @override
  void dispose() {
    super.dispose();
    cardSnapshot?.dispose();
  }
}

PageRouteBuilder<T> containerTransformRoute<T>({
  required WidgetBuilder builder,
  Rect? fromRect,
  BorderRadius? fromRadius,
  RouteSettings? settings,
}) {
  final hasSource = fromRect != null && !fromRect.isEmpty;
  final cardSnapshot = ContainerTransformSource._takeSnapshot(fromRect);
  return _ContainerTransformRoute<T>(
    cardSnapshot: cardSnapshot,
    settings: settings,
    // Keeping the source route visible also prevents its Cupertino transition
    // from reacting to this route's secondary animation. No barrier dims it.
    // 有来源卡片：从卡片位置长到整屏。
    // 没有来源（比如从设置页打开「关于软件」）：不套这个动效，但也要有过渡。
    transitionDuration: hasSource
        ? containerTransformForwardDuration
        : containerTransformPlainDuration,
    reverseTransitionDuration: hasSource
        ? containerTransformReverseDuration
        : containerTransformPlainDuration,
    pageBuilder: (context, _, _) => builder(context),
    transitionsBuilder: (context, animation, _, child) {
      // 这个动效只属于「从首页卡片打开一个页面」。
      // 之前不管从哪进来都硬跑一次，还把首页的缩略图当背景画出来 ——
      // 从设置页打开「关于软件」时就露出了主页，明显不对。
      if (!hasSource) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          if (size.width > containerTransformSplitBreakpoint) return child;
          final corners = MediaQuery.displayCornerRadiiOf(context);
          final screenRadius = [
            corners?.topLeft.x ?? 0.0,
            corners?.topLeft.y ?? 0.0,
            corners?.topRight.x ?? 0.0,
            corners?.topRight.y ?? 0.0,
            corners?.bottomLeft.x ?? 0.0,
            corners?.bottomLeft.y ?? 0.0,
            corners?.bottomRight.x ?? 0.0,
            corners?.bottomRight.y ?? 0.0,
          ].reduce(math.max);
          final rectTween = ContainerTransformRectTween(
            begin: fromRect,
            end: Offset.zero & size,
          );
          final startRadius = fromRadius ?? BorderRadius.circular(14);
          final endRadius = BorderRadius.circular(screenRadius);
          return AnimatedBuilder(
            animation: animation,
            // 页面按整屏尺寸构建（第一帧就是），下面只裁不缩。
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
            builder: (context, page) {
              final raw = animation.value;
              // 不要在收尾处直接交回 child：那样会把 _SinkDriver 一起卸掉
              // （下沉值归零会打断首页），而且从"快照版"硬切到真页面时，
              // 异步才画出来的内容（比如课表壁纸）会突然出现。
              // 现在整条路由保持同一棵树，收尾由 surface 自己做 120ms 淡出。
              final t = Curves.fastOutSlowIn.transform(raw);
              final window = rectTween.lerp(t)!;
              // 等比铺满窗口所需的最小缩放（相当于 BoxFit.cover）。
              final coverScale = math.max(
                window.width / size.width,
                window.height / size.height,
              );
              final pageOffset = Offset(
                window.center.dx - size.width * coverScale / 2,
                window.center.dy - size.height * coverScale / 2,
              );
              // Position the image in page coordinates so the shared transform
              // maps it exactly onto the growing window, without cover cropping.
              final cardRect = Rect.fromLTWH(
                (window.left - pageOffset.dx) / coverScale,
                (window.top - pageOffset.dy) / coverScale,
                window.width / coverScale,
                window.height / coverScale,
              );
              final cardAlpha = (1 - t / 0.4).clamp(0.0, 1.0);
              return Stack(
                children: [
                  // 驱动首页那层的"下沉"（首页在另一个 Navigator，只能靠全局值联动）。
                  _SinkDriver(animation: animation),
                  // 背景：**直接模糊活的背景**（BackdropFilter）。
                  // 之前试过「抓首页截图 + 在小图上模糊 + 放大」那套（小米专利的省算力做法），
                  // 但截图不会跟着首页一起下沉，于是截图和真实首页错开，看着是叠影。
                  // 模糊活内容就没这个问题。模糊半径同样从 0 长大，
                  // 所以第一帧和首页完全一致，不会跳变。
                  Positioned.fill(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (t > 0.001)
                          BackdropFilter(
                            filter: ui.ImageFilter.blur(
                              sigmaX: 10 * t,
                              sigmaY: 10 * t,
                            ),
                            child: const ColoredBox(color: Color(0x00000000)),
                          ),
                        ColoredBox(
                          color: Colors.black.withValues(alpha: 0.32 * t),
                        ),
                      ],
                    ),
                  ),
                  // 页面**等比铺满**正在长大的窗口（相当于 BoxFit.cover），
                  // 但动画期间画的是它的**快照**，不是它本人。
                  //
                  // 为什么：课表这类重页面内部有 ImageFiltered(壁纸模糊)、MaskFilter.blur(面板阴影)
                  // 和大量裁切，被外层「每帧变化的缩放 + 裁切」一折腾，栅格化缓存就用不上了，
                  // 于是每帧都在重做滤镜 —— 实测很卡。快照方案把动画期间要画的东西
                  // 压缩成**一张位图**：缩放与裁切都只作用在这张图上，必顺。
                  // （页面本身仍然照常构建、布局、保持存活，只是动画期间不参与绘制；
                  //   落地时把快照撤掉，露出来的就是已经建好的真实页面，无缝、不重建。）
                  Positioned.fill(
                    child: ClipPath(
                      clipper: _TransformWindowClipper(
                        rect: window,
                        radius: BorderRadius.lerp(startRadius, endRadius, t)!,
                      ),
                      child: Transform(
                        alignment: Alignment.topLeft,
                        transform: Matrix4.identity()
                          ..translateByDouble(
                            pageOffset.dx,
                            pageOffset.dy,
                            0,
                            1,
                          )
                          ..scaleByDouble(coverScale, coverScale, 1, 1),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _ContainerTransformSurface(
                              showSnapshot: raw < 0.999,
                              child: ColoredBox(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                child: page,
                              ),
                            ),
                            if (cardSnapshot != null && cardAlpha > 0)
                              Positioned.fromRect(
                                rect: cardRect,
                                child: IgnorePointer(
                                  child: RawImage(
                                    image: cardSnapshot,
                                    fit: BoxFit.contain,
                                    color: Colors.white.withValues(
                                      alpha: cardAlpha,
                                    ),
                                    colorBlendMode: BlendMode.modulate,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
