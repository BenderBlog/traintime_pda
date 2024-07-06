// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
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
                factoryBuilder: () => MyWidgetFactory(),
              );
            } catch (e) {
              return ReloadWidget(
                function: () {
                  setState(() {
                    content = PlanetSession().content(widget.article.content);
                  });
                },
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
          return SelectionArea(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: widget.article.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    TextSpan(
                      text: "\n${widget.author} - "
                          "${Jiffy.parseFromDateTime(widget.article.time).format(pattern: "yyyy年MM月dd日 HH:mm")}",
                    ),
                  ]),
                ),
                const Divider(),
                addon
              ],
            ).constrained(
              maxWidth: sheetMaxWidth - 16,
              minWidth: min(
                MediaQuery.of(context).size.width,
                sheetMaxWidth - 16,
              ),
            ),
          );
        },
      ).center().safeArea(),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
