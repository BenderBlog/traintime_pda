// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Content page of XDU Planet.
/*
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/xdu_planet/comment_popout.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';
import 'package:watermeter/generated/l10n.dart';

class ContentPage extends StatefulWidget {
  final Article article;
  final String author;

  const ContentPage({super.key, required this.article, required this.author});

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
  <h3>${I18n.of(context)!.xduPlanetLoadFailedTitle}</h3>
  <p>${I18n.of(context)!.xduPlanetLoadFailedBottom}</p>
''',
                  factoryBuilder: () => MyWidgetFactory(),
                );
              } catch (e) {
                return ReloadWidget(
                  function: () {
                    setState(() {
                      _content = PlanetSession().content(
                        widget.article.content,
                      );
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
                  TextSpan(
                    children: [
                      TextSpan(
                        text: widget.article.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      TextSpan(
                        text:
                            "\n${widget.author} - "
                            "${DateFormat("yyyy-MM-dd HH:mm").format(widget.article.time)}",
                      ),
                    ],
                  ),
                ),
                const Divider(),
                addon,
              ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
            );
          },
        ),
        const Divider(),
        ListenableBuilder(
          listenable: _comments,
          builder: (BuildContext context, Widget? child) => FutureBuilder<List<XDUPlanetComment>>(
            future: _comments.comments,
            builder: (context, snapshot) {
              late Widget list;
              if (snapshot.connectionState == ConnectionState.done) {
                try {
                  if (snapshot.data!.isEmpty) {
                    list = Text(
                      I18n.of(context)!.xduPlanetNoComment,
                    );
                  } else {
                    list = List.generate(
                      snapshot.data!.length,
                      (index) => ListTile(
                        title: Text(
                          "#${snapshot.data![index].ID} "
                          "${snapshot.data![index].user_id} "
                          "${FlutterI18n.translate(context, snapshot.data![index].statusStr)}",
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("yyyy-MM-dd HH:mm:ss").format(
                                snapshot.data![index].CreatedAt.toLocal(),
                              ),
                            ),
                            if (snapshot.data![index].reply_to.isNotEmpty)
                              Builder(
                                builder: (context) {
                                  // No need to think about orelse.
                                  XDUPlanetComment? data = snapshot.data!
                                      .firstWhereOrNull(
                                        (element) =>
                                            element.ID.toString() ==
                                            snapshot.data![index].reply_to,
                                      );
                                  if (data == null) {
                                    return Text(
                                      I18n.of(context)!.xduPlanetReplyAudit(snapshot.data![index].reply_to),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }
                                  return Text(
                                    I18n.of(context)!.xduPlanetReply(snapshot.data![index].reply_to, data.content),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            const SizedBox(height: 4),
                            Text(
                              snapshot.data![index].content,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ).gestures(
                              onTap: () => BothSideSheet.show(
                                context: context,
                                title:
                                    "#${snapshot.data![index].ID} "
                                    "${snapshot.data![index].user_id} "
                                    "${snapshot.data![index].statusStr}",
                                child: Text(snapshot.data![index].content),
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
                                        msg: I18n.of(context)!.xduPlanetHaveBeenAudit,
                                      );
                                      return;
                                    }
                                    bool isConfirm =
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                            title: Text(
                                              I18n.of(context)!.xduPlanetConfirmAuditDialogTitle,
                                            ),
                                            content: Text(
                                              I18n.of(context)!.xduPlanetConfirmAuditDialogContent,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text(
                                                  I18n.of(context)!.xduPlanetConfirmAuditDialogCancel,
                                                ),
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                              ),
                                              TextButton(
                                                child: Text(
                                                  I18n.of(context)!.confirm,
                                                ),
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;
                                    if (isConfirm && context.mounted) {
                                      var pd = ProgressDialog(context: context);
                                      pd.show(
                                        msg: I18n.of(context)!.xduPlanetConfirmAuditDialogOngoing,
                                      );
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
                                                msg: I18n.of(context)!.xduPlanetConfirmAuditDialogSuccess,
                                              );
                                            }
                                          })
                                          .onError((e, _) {
                                            pd.close();
                                            if (context.mounted) {
                                              showToast(
                                                context: context,
                                                msg: I18n.of(context)!.xduPlanetConfirmAuditDialogFailed,
                                              );
                                            }
                                          });
                                    }
                                  },
                                  child: Text(
                                    I18n.of(context)!.xduPlanetAudit,
                                  ),
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
                                          msg: I18n.of(context)!.xduPlanetCommentSuccess,
                                        );
                                      } else if (result == false) {
                                        showToast(
                                          context: context,
                                          msg: I18n.of(context)!.xduPlanetCommentFailed,
                                        );
                                      } else {
                                        showToast(
                                          context: context,
                                          msg: I18n.of(context)!.xduPlanetCommentCanceled,
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    I18n.of(context)!.xduPlanetComment,
                                  ),
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
                return Text(
                  I18n.of(context)!.xduPlanetCommentLoading,
                );
              }
              return SelectionArea(child: list);
            },
          ),
        ),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.center).padding(all: 12).width(double.infinity).constrained(maxWidth: sheetMaxWidth).center().scrollable(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await showDialog<bool>(
            context: context,
            builder: (context) => CommentPopout(id: widget.article.id),
          );
          if (context.mounted) {
            if (result == true) {
              /// Temporary solution...
              _comments.update();
              showToast(
                context: context,
                msg: I18n.of(context)!.xduPlanetCommentSuccess,
              );
            } else if (result == false) {
              showToast(
                context: context,
                msg: I18n.of(context)!.xduPlanetCommentFailed,
              );
            } else {
              showToast(
                context: context,
                msg: I18n.of(context)!.xduPlanetCommentCanceled,
              );
            }
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
*/
