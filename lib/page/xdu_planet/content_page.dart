// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';
import 'package:watermeter/repository/logger.dart';

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
  late Future<String> _content;
  late Future<List<XDUPlanetComment>> _comments;
  final TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _content = PlanetSession().content(widget.article.content);
    _comments = PlanetSession().getComments(widget.article.id);
  }

  @override
  void didUpdateWidget(covariant ContentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _content = PlanetSession().content(widget.article.content);
    _comments = PlanetSession().getComments(widget.article.id);
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
      body: [
        FutureBuilder<String>(
          future: _content,
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
                      _content =
                          PlanetSession().content(widget.article.content);
                    });
                  },
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
            return SelectionArea(
              child: [
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
              ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
            );
          },
        ),
        const Divider(),
        FutureBuilder<List<XDUPlanetComment>>(
          future: _comments,
          builder: (context, snapshot) {
            late Widget list;
            if (snapshot.connectionState == ConnectionState.done) {
              try {
                if (snapshot.data!.isEmpty) {
                  list = const Text("暂无评论");
                } else {
                  list = Column(
                    children: List.generate(
                      snapshot.data!.length,
                      (index) => ListTile(
                        title: Text(snapshot.data![index].user_id),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data![index].CreatedAt.toString()),
                            const SizedBox(height: 5),
                            Text(snapshot.data![index].content),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // 举报按钮功能
                                  },
                                  child: const Text('举报'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 回复按钮功能
                                  },
                                  child: const Text('回复'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              } catch (e) {
                return ReloadWidget(
                  function: () {
                    setState(() {
                      _comments =
                          PlanetSession().getComments(widget.article.id);
                    });
                  },
                );
              }
            } else {
              return const Text("加载评论中……");
            }
            return SelectionArea(
              child: [
                list,
                const Divider(),
                Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '输入你的评论...',
                        border: OutlineInputBorder(),
                      ),
                    ).padding(all: 8).expanded(),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        print(_controller.text);
                        await PlanetSession()
                            .sendComments(
                          id: widget.article.id,
                          content: _controller.text,
                          userId: "PDA User",
                          replyto: null,
                        )
                            .then((value) {
                          setState(() {
                            _controller.text = "";
                            _comments =
                                PlanetSession().getComments(widget.article.id);
                          });
                        }).onError((e, s) {
                          log.e(e.toString());
                          Fluttertoast.showToast(msg: "评论发送失败");
                        });
                      },
                    ),
                  ].toRow(),
                )
              ].toColumn(),
            );
          },
        ),
      ]
          .toColumn()
          .padding(all: 12)
          .constrained(
            maxWidth: sheetMaxWidth - 24,
            minWidth: min(
              MediaQuery.of(context).size.width,
              sheetMaxWidth - 24,
            ),
          )
          .scrollable()
          .safeArea(),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
