/*
Content page of XDU Planet.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' hide Content;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
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
          String addon = "";
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              addon = snapshot.data?.content ??
                  '''
  <h3>遇到错误</h3>
  <p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
  </p>
''';
            } catch (e, s) {
              addon = "加载遇到错误: $e, $s";
            }
          } else {
            addon = "正在加载...";
          }
          return SingleChildScrollView(
            child: Html(data: "$title<br><p>$addon</p>"),
          );
        },
      ),
    );
  }
}
