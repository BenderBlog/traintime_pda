// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';

class WheelChooseOptions<T> {
  T data;
  String hint;

  WheelChooseOptions({required this.data, required this.hint});
}

class WheelChoose<T> extends StatefulWidget {
  final ValueChanged<T> changeBookIdCallBack;
  final List<WheelChooseOptions<T>> options;
  final int defaultPage;

  const WheelChoose({
    super.key,
    required this.changeBookIdCallBack,
    required this.options,
    this.defaultPage = 0,
  });

  @override
  State<WheelChoose<T>> createState() => _WheelChooseState<T>();
}

class _WheelChooseState<T> extends State<WheelChoose<T>> {
  static const double _heightOfText = 30;
  static const double _widthOfLine = 1;
  late final PageController _pageController;

  // 通过记录最近一次已经选中的页面，用于区分用户滚动触发的回调与外部状态更新。
  // 用户滚动后，onPageChanged 会先更新 _selectedPage；随后父组件因回调而重建时，
  // didUpdateWidget 就不会再次 animateToPage，
  // 即新一轮的 widget.defaultPage == _selectedPage，避免了重复动画。
  //
  // 这是保证当前功能正确的最小修改：当前调用场景中 defaultPage 由用户选择驱动，
  // 因此只需跳过同一页面的重复同步即可。它没有完整维护 PageView 的滚动状态，
  // 以下情况仍可能出现页面状态短暂不一致：
  // 1. animateToPage 尚未完成就被用户手势或其他滚动操作中断；
  // 2. 用户正在拖动时，外部突然修改 defaultPage；
  // 3. options 内容被替换但页面索引和 defaultPage 没有变化。
  // 这些情况需要同时监听滚动状态或重建控制器，属于当前业务场景之外的边界用法。
  // 等实际出现这些问题时，再做加强。
  late int _selectedPage;

  @override
  void initState() {
    super.initState();
    _selectedPage = widget.defaultPage;
    _pageController = PageController(
      viewportFraction: 1 / 3,
      initialPage: widget.defaultPage,
    );
  }

  @override
  void didUpdateWidget(covariant WheelChoose<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.defaultPage != widget.defaultPage &&
        widget.defaultPage != _selectedPage) {
      _selectedPage = widget.defaultPage;
      _pageController.animateToPage(
        widget.defaultPage,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: _heightOfText)
            .border(
              top: _widthOfLine,
              bottom: _widthOfLine,
              color: Theme.of(context).colorScheme.primary,
            )
            .center(),
        PageView.builder(
          itemCount: widget.options.length,
          controller: _pageController,
          scrollDirection: Axis.vertical,
          pageSnapping: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            return Text(
              widget.options[index].hint,
            ).textColor(Theme.of(context).colorScheme.primary).center();
          },
          onPageChanged: (int index) {
            _selectedPage = index;
            widget.changeBookIdCallBack(widget.options[index].data);
          },
        ),
      ],
    ).height(_heightOfText * 3).alignment(Alignment.center).center();
  }
}
