// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
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
  void initState() {
    super.initState();
    content = PlanetSession().content(widget.article.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
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
          String title = '''
<h2>${widget.article.title}</h2>
<i>by: ${widget.author}</i></br>
<i>at: ${Jiffy.parseFromDateTime(widget.article.time).format(pattern: "yyyy年MM月dd日")}</i>
''';
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
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                child: HtmlWidget(
                  title,
                ),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: sheetMaxWidth - 16,
                    minWidth: min(
                      MediaQuery.of(context).size.width,
                      sheetMaxWidth - 16,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    child: addon,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
