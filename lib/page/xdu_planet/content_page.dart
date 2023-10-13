// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class ContentPage extends StatefulWidget {
  final String feed;
  final int index;
  final String authorName;
  final String title;
  final String time;
  final String link;

  const ContentPage({
    super.key,
    required this.feed,
    required this.index,
    required this.authorName,
    required this.title,
    required this.time,
    required this.link,
  });

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<Content> content;

  @override
  void initState() {
    super.initState();
    content = PlanetSession().content(widget.feed, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => launchUrlString(
              widget.link,
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: FutureBuilder<Content>(
        future: content,
        builder: (context, snapshot) {
          String title = '''
<h2>${widget.title}</h2>
<i>by: ${widget.authorName}</i></br>
<i>at: ${widget.time}</i>
''';
          late Widget addon;
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              addon = HtmlWidget(
                snapshot.data?.content ??
                    '''
  <h3>遇到错误</h3>
  <p>
    很有可能是你没用接上互联网。
  </p>
''',
                renderMode: RenderMode.listView,
              );
            } catch (e) {
              addon = ReloadWidget(
                function: () {
                  setState(() {
                    content =
                        PlanetSession().content(widget.feed, widget.index);
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
