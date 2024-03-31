// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/split_view.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class ContentPage extends StatefulWidget {
  final Article article;
  final String author;

  const ContentPage({
    super.key,
    required this.article,
    required this.author,
  });

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<String> content;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    content = PlanetSession().content(widget.article.content);
  }

  @override
  void didUpdateWidget(covariant ContentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    content = PlanetSession().content(widget.article.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () {
            SplitView.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => launchUrlString(
              widget.article.url,
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: content,
        builder: (context, snapshot) {
          late Widget addon;
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              addon = HtmlWidget(
                snapshot.data ??
                    '''
  <h3>遇到错误</h3>
  <p>
    文章加载失败，如有需要可以点击右上方的按钮在浏览器里打开。
  </p>
''',
                renderMode: RenderMode.listView,
              );
            } catch (e) {
              addon = ReloadWidget(
                function: () {
                  setState(() {
                    content = PlanetSession().content(widget.article.content);
                  });
                },
              );
            }
          } else {
            addon = const Center(child: CircularProgressIndicator());
          }
          return [
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: widget.article.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "\nby: ${widget.author}",
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(
                  text: "\nat: "
                      "${Jiffy.parseFromDateTime(widget.article.time).format(pattern: "yyyy年MM月dd日")}",
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]),
            ).padding(all: 8),
            //HtmlWidget(title),
            addon
                .padding(
                  left: 8,
                  right: 8,
                  bottom: 8,
                )
                .expanded(),
          ]
              .toColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
              )
              .constrained(
                  maxWidth: sheetMaxWidth - 16,
                  minWidth: min(
                    MediaQuery.of(context).size.width,
                    sheetMaxWidth - 16,
                  ))
              .safeArea();
        },
      ),
    );
  }
}
