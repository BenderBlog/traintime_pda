// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// From https://blog.csdn.net/zl18603543572/article/details/125757856

import 'dart:async';
import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int loopSeconds;
  const MarqueeWidget({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.loopSeconds = 5,
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late PageController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(
      Duration(seconds: widget.loopSeconds),
      (timer) {
        if (_controller.page != null) {
          if (_controller.page!.round() >= widget.itemCount) {
            _controller.jumpToPage(0);
          }
          _controller.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      controller: _controller,
      itemBuilder: (buildContext, index) {
        if (index < widget.itemCount) {
          return widget.itemBuilder(buildContext, index);
        } else {
          return widget.itemBuilder(buildContext, 0);
        }
      },
      itemCount: widget.itemCount + 1,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _timer.cancel();
  }
}
