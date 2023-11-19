// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class PageChooseOptions<T> {
  T data;
  String hint;

  PageChooseOptions({
    required this.data,
    required this.hint,
  });
}

class PageChoose<T> extends StatelessWidget {
  final ValueChanged<T> changeBookIdCallBack;
  final List<PageChooseOptions<T>> options;

  final double heightOfText = 30;
  final double widthOfLine = 1;

  final PageController pagecontroller = PageController(
    viewportFraction: 1 / 3,
    initialPage: 1,
  );

  PageChoose({
    super.key,
    required this.changeBookIdCallBack,
    required this.options,
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
          controller: pagecontroller,
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
