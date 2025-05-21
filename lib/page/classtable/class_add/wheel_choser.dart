// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class WheelChooseOptions<T> {
  T data;
  String hint;

  WheelChooseOptions({
    required this.data,
    required this.hint,
  });
}

class WheelChoose<T> extends StatelessWidget {
  final ValueChanged<T> changeBookIdCallBack;
  final List<WheelChooseOptions<T>> options;
  final int defaultPage;

  final double heightOfText = 30;
  final double widthOfLine = 1;

  const WheelChoose({
    super.key,
    required this.changeBookIdCallBack,
    required this.options,
    this.defaultPage = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: heightOfText)
            .border(
              top: widthOfLine,
              bottom: widthOfLine,
              color: Theme.of(context).colorScheme.primary,
            )
            .center(),
        PageView.builder(
          itemCount: options.length,
          controller: PageController(
            viewportFraction: 1 / 3,
            initialPage: defaultPage,
          ),
          scrollDirection: Axis.vertical,
          pageSnapping: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            return Text(options[index].hint)
                .textColor(Theme.of(context).colorScheme.primary)
                .center();
          },
          onPageChanged: (int index) {
            changeBookIdCallBack(options[index].data);
          },
        ),
      ],
    ).height(heightOfText * 3).alignment(Alignment.center).center();
  }
}
