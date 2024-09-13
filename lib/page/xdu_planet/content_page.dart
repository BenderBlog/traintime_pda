// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.

import 'dart:async';
import 'dart:math' show min;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
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

  String? content(String? content) {
    if (content == null) return null;
    List<String> split = content.split('<hr />');
    RegExp latexStuff = RegExp(r'(\$+)((?:(?!\1)[\s\S])*)\1');
    String tail = split.last.replaceAllMapped(
      latexStuff,
      (match) {
        if (match.group(2) == null) return "";
        String parseMiddle = match
            .group(2)!
            .replaceAll(RegExp(r'<br(.*)>'), "")
            .replaceAll("&lt;", "<")
            .replaceAll("&gt;", ">")
            .replaceAll("&quot;", "\"")
            .replaceAll("&#39;", "'")
            .replaceAll("&amp;", "\\&")
            .replaceAll("\\begin{align}", "")
            .replaceAll("\\end{align}", "");
        return "${match.group(1)}$parseMiddle${match.group(1)}";
      },
    );
    return html2md.convert(tail).replaceAll(r"\\", r'\');
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
                addon = MarkdownBody(
                  selectable: true,
                  builders: {
                    'latex': LatexElementBuilder(),
                  },
                  extensionSet: md.ExtensionSet(
                    [LatexBlockSyntax()],
                    [LatexInlineSyntax()],
                  ),
                  data: content(snapshot.data) ??
                      '''
  ### 遇到错误
  
  文章加载失败，如有需要可以点击右上方的按钮在浏览器里打开。
  
''',
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
                          "${widget.article.articleTime.format(pattern: "yyyy年MM月dd日 HH:mm")}",
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
                            ).toLocal().format(pattern: 'yyyy-MM-dd HH:mm:ss')),
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
                                  "回复评论 #${snapshot.data![index].reply_to}：${data.content}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            const SizedBox(height: 4),
                            Text(
                              snapshot.data![index].content,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ).gestures(
                              onTap: () => BothSideSheet.show(
                                context: context,
                                title: "#${snapshot.data![index].ID} "
                                    "${snapshot.data![index].user_id} "
                                    "${snapshot.data![index].statusStr}",
                                child: Text(snapshot.data![index].content)
                                    .safeArea(),
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    if (snapshot.data![index].status != "ok" &&
                                        context.mounted) {
                                      showToast(
                                        context: context,
                                        msg: "本评论已经被举报",
                                      );
                                      return;
                                    }
                                    bool isConfirm = await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                  title: const Text('确认是否举报'),
                                                  content: const Text(
                                                    '三思而后行，确定您想举报吗？举报后该评论会有标签，不一定会删除。',
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('不举报了'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                    ),
                                                    TextButton(
                                                      child: const Text('确认'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                    ),
                                                  ],
                                                )) ??
                                        false;
                                    if (isConfirm && context.mounted) {
                                      var pd = ProgressDialog(context: context);
                                      pd.show(msg: "正在举报评论");
                                      PlanetSession()
                                          .auditComments(
                                        id: snapshot.data![index].ID,
                                      )
                                          .then((value) {
                                        pd.close();
                                        _comments.update();
                                        if (context.mounted) {
                                          showToast(
                                            context: context,
                                            msg: "举报成功",
                                          );
                                        }
                                      }).onError((e, _) {
                                        pd.close();
                                        if (context.mounted) {
                                          showToast(
                                            context: context,
                                            msg: "举报失败",
                                          );
                                        }
                                      });
                                    }
                                  },
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
                                    if (context.mounted) {
                                      if (result == true) {
                                        /// Temporary solution...
                                        _comments.update();
                                        showToast(
                                          context: context,
                                          msg: "评论成功",
                                        );
                                      } else if (result == false) {
                                        showToast(
                                          context: context,
                                          msg: "评论失败，请去网络查看器和日志查看器查看报错",
                                        );
                                      } else {
                                        showToast(
                                          context: context,
                                          msg: "没想好要说啥嘛",
                                        );
                                      }
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
          if (context.mounted) {
            if (result == true) {
              /// Temporary solution...
              _comments.update();
              showToast(
                context: context,
                msg: "评论成功",
              );
            } else if (result == false) {
              showToast(
                context: context,
                msg: "评论失败，请去网络查看器和日志查看器查看报错",
              );
            } else {
              showToast(context: context, msg: "没想好要说啥嘛");
            }
          }
        },
        child: const Icon(Icons.comment),
      ),
    );
  }
}

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
