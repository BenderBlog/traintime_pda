// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/xdu_planet/comment_popout.dart';
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
  late Future<String> _content;
  late CommentModel _comments;

  @override
  void initState() {
    super.initState();
    _content = PlanetSession().content(widget.article.content);
    _comments = CommentModel(id: widget.article.id);
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
        ListenableBuilder(
          listenable: _comments,
          builder: (BuildContext context, Widget? child) =>
              FutureBuilder<List<XDUPlanetComment>>(
            future: _comments.comments,
            builder: (context, snapshot) {
              late Widget list;
              if (snapshot.connectionState == ConnectionState.done) {
                try {
                  if (snapshot.data!.isEmpty) {
                    list = const Text("暂无评论");
                  } else {
                    list = List.generate(
                      snapshot.data!.length,
                      (index) => ListTile(
                        title: Text(
                          "#${snapshot.data![index].ID} "
                          "${snapshot.data![index].user_id} "
                          "${snapshot.data![index].statusStr}",
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Jiffy.parseFromDateTime(
                              snapshot.data![index].CreatedAt,
                            ).format(pattern: 'yyyy-MM-dd HH:mm:ss')),
                            if (snapshot.data![index].reply_to.isNotEmpty)
                              Builder(builder: (context) {
                                // No need to think about orelse.
                                XDUPlanetComment? data =
                                    snapshot.data!.firstWhereOrNull(
                                  (element) =>
                                      element.ID.toString() ==
                                      snapshot.data![index].reply_to,
                                );
                                if (data == null) {
                                  return Text(
                                    "回复评论 #${snapshot.data![index].reply_to} 已被举报或删除",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                                return Text(
                                  "回复评论 #${snapshot.data![index].ID}：${data.content}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            const SizedBox(height: 4),
                            Text(snapshot.data![index].content),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => PlanetSession()
                                      .auditComments(
                                    id: snapshot.data![index].ID,
                                  )
                                      .then((value) {
                                    _comments.update();
                                    Fluttertoast.showToast(msg: "举报成功");
                                  }).onError((e, _) {
                                    Fluttertoast.showToast(msg: "举报失败");
                                  }),
                                  child: const Text('举报'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    bool? result =
                                        await showModalBottomSheet<bool>(
                                      context: context,
                                      builder: (context) => CommentPopout(
                                        id: widget.article.id,
                                        replyTo: snapshot.data![index],
                                      ),
                                    );
                                    if (result == true) {
                                      /// Temporary solution...
                                      _comments.update();
                                      Fluttertoast.showToast(msg: "评论成功");
                                    } else if (result == false) {
                                      Fluttertoast.showToast(
                                          msg: "评论失败，请去网络查看器和日志查看器查看报错");
                                    } else {
                                      Fluttertoast.showToast(msg: "没想好要说啥嘛");
                                    }
                                  },
                                  child: const Text('回复'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).toColumn();
                  }
                } catch (e) {
                  return ReloadWidget(function: _comments.update);
                }
              } else {
                return const Text("加载评论中……");
              }
              return SelectionArea(
                child: list,
              );
            },
          ),
        ),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await showModalBottomSheet<bool>(
            context: context,
            builder: (context) => CommentPopout(id: widget.article.id),
          );
          if (result == true) {
            /// Temporary solution...
            _comments.update();
            Fluttertoast.showToast(msg: "评论成功");
          } else if (result == false) {
            Fluttertoast.showToast(msg: "评论失败，请去网络查看器和日志查看器查看报错");
          } else {
            Fluttertoast.showToast(msg: "没想好要说啥嘛");
          }
        },
        child: const Icon(Icons.comment),
      ),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}

class CommentModel with ChangeNotifier {
  String id;
  late Future<List<XDUPlanetComment>> comments;

  CommentModel({required this.id}) {
    update();
  }

  void update() {
    comments = PlanetSession().getComments(id);
    notifyListeners();
  }
}
