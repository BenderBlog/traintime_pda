// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:watermeter/page/club_suggestion/club_image_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/pda_service_session.dart';

class ClubDetail extends StatefulWidget {
  final String code;
  const ClubDetail({super.key, required this.code});

  @override
  State<ClubDetail> createState() => _ClubDetailState();
}

class _ClubDetailState extends State<ClubDetail> {
  late Future<ResultDart<ClubInfo, Exception>> _future;

  @override
  void initState() {
    super.initState();
    if (widget.code.isNotEmpty) {
      _future = getClubInfo(widget.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.code.isEmpty
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                FlutterI18n.translate(context, "club_promotion.wrong_param"),
              ),
            ),
            body: Text(
              FlutterI18n.translate(context, "club_promotion.no_group_info"),
            ).center(),
          )
        : FutureBuilder<ResultDart<ClubInfo, Exception>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      FlutterI18n.translate(context, "club_promotion.loading"),
                    ),
                  ),
                  body: CircularProgressIndicator().center(),
                );
              }

              if (snapshot.hasError) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      FlutterI18n.translate(
                        context,
                        "club_promotion.error_outside",
                      ),
                    ),
                  ),
                  body: ReloadWidget(
                    function: () => setState(() {
                      _future = getClubInfo(widget.code);
                    }),
                    errorStatus: snapshot.error,
                  ),
                );
              }

              return snapshot.data!.fold(
                (success) => ClubDetailPage(info: success),
                (failure) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      FlutterI18n.translate(context, "club_promotion.error"),
                    ),
                  ),
                  body: ReloadWidget(
                    function: () => setState(() {
                      _future = getClubInfo(widget.code);
                    }),
                    errorStatus: failure,
                  ),
                ),
              );
            },
          );
  }
}

class ClubDetailPage extends StatefulWidget {
  final ClubInfo info;

  const ClubDetailPage({super.key, required this.info});

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  late ScrollController _scrollController;
  late Future<String> _content;
  final List<ImageProvider> _image = [];

  static const _expandedHeight = 310.0;
  static const _maxWidth = 800.0;

  double _opacity = 0.0;

  void _scrollListener() {
    _opacity = (_scrollController.offset / (_expandedHeight - kToolbarHeight));
    if (_opacity < 0.0) _opacity = 0.0;
    if (_opacity >= 1.0) _opacity = 1.0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _content = getClubArticle(widget.info.code);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    if (widget.info.pic > 0) {
      for (var index in Iterable.generate(widget.info.pic)) {
        _image.add(NetworkImage(getClubImage(widget.info.code, index)));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: widget.info.color,
          brightness: Theme.of(context).brightness,
        ),
      ),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: _expandedHeight,
              centerTitle: false,
              pinned: true,
              title: Opacity(opacity: _opacity, child: Text(widget.info.title)),
              actions: [
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: widget.info.qq),
                    );
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: FlutterI18n.translate(
                          context,
                          "club_promotion.qq_copied",
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.chat),
                ),

                IconButton(
                  onPressed: () async {
                    if (widget.info.qqlink.isEmpty) {
                      showToast(
                        context: context,
                        msg: FlutterI18n.translate(
                          context,
                          "club_promotion.no_link",
                        ),
                      );
                    }
                    launchUrlString(widget.info.qqlink);
                  },
                  icon: Icon(Icons.link),
                ),
              ],
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(
                    0,
                    kToolbarHeight,
                    0,
                    46,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image(
                          image: widget.info.icon,
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.info.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.info.intro),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...widget.info.type.map<Widget>(
                            (type) => Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 2,
                              ),
                              child: TagsBoxes(
                                text: FlutterI18n.translate(
                                  context,
                                  type.getTypeName(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height - kToolbarHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FutureBuilder<String>(
                      future: _content,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Padding(
                            padding: EdgeInsetsGeometry.only(bottom: 2),
                            child: LinearProgressIndicator(),
                          );
                        } else {
                          return SizedBox(height: 6);
                        }
                      },
                    ),

                    if (widget.info.pic > 0) ...[
                      Container(
                        height: 300,
                        constraints: BoxConstraints(maxWidth: 600),
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(12),
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: widget.info.pic,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 4,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(12),
                                ),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ClubImageView(
                                          color: widget.info.color,
                                          images: _image,
                                          initalPage: index,
                                        );
                                      },
                                    ),
                                  ),
                                  child: Image(
                                    image: _image[index],
                                    height: 300,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(color: Colors.transparent),
                    ],
                    FutureBuilder<String>(
                      future: _content,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          try {
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: _maxWidth),
                              child: Padding(
                                padding: EdgeInsetsGeometry.only(
                                  left: 8,
                                  right: 8,
                                ),
                                child: HtmlWidget(
                                  snapshot.data ??
                                      '''<p>${FlutterI18n.translate(context, "club_promotion.loading_problem")}</p>''',
                                ),
                              ),
                            );
                          } catch (e) {
                            return ReloadWidget(
                              function: () {
                                setState(() {
                                  _content = getClubArticle(widget.info.code);
                                });
                              },
                            );
                          }
                        } else {
                          return SizedBox(height: 0);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
