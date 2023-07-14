/*
Content page of XDU Planet.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' hide Content;
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class ContentPage extends StatefulWidget {
  final String name;
  final int index;
  const ContentPage({
    super.key,
    required this.name,
    required this.index,
  });

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<Content> content;

  @override
  void initState() {
    super.initState();
    content = PlanetSession().content(widget.name, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: FutureBuilder<Content>(
        future: content,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              return SingleChildScrollView(
                  child: Html(
                      data: snapshot.data?.content ??
                          '''
  <h3>遇到错误</h3>
  <p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
  </p>
  <!-- anything goes here -->

'''));
            } catch (e, s) {
              return Text("Error: $e, $s");
            }
          } else {
            return const Text("Loading...");
          }
        },
      ),
    );
  }
}
