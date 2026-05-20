// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1 / 3,
      initialPage: widget.defaultPage,
    );
  }

  @override
  void didUpdateWidget(covariant WheelChoose<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultPage != widget.defaultPage) {
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
            widget.changeBookIdCallBack(widget.options[index].data);
          },
        ),
      ],
    ).height(_heightOfText * 3).alignment(Alignment.center).center();
  }
}
