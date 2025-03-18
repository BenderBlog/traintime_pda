// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:styled_widget/styled_widget.dart';

class HelpGuide extends StatelessWidget {
  const HelpGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Need help?"),
      ),
      body: FutureBuilder(
        future: DefaultAssetBundle.of(context)
            .load('assets/guide/README.html')
            .then((value) => utf8.decode(value.buffer.asUint8List(
                  value.offsetInBytes,
                  value.lengthInBytes,
                )..cast<int>())),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 资源加载完成，显示图片
            return HtmlWidget(snapshot.data!)
                .constrained(maxWidth: 480)
                .padding(all: 12)
                .scrollable()
                .center();
          } else {
            // 资源加载中，显示加载指示器
            return const CircularProgressIndicator().center();
          }
        },
      ),
    );
  }
}
