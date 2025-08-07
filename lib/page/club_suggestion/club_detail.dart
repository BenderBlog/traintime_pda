import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/pda_service_session.dart';

class ClubDetail extends StatefulWidget {
  final ClubInfo info;

  const ClubDetail({super.key, required this.info});

  @override
  State<ClubDetail> createState() => _ClubDetailState();
}

class _ClubDetailState extends State<ClubDetail> {
  late ScrollController _scrollController;
  late Future<String> _content;

  static const _expandedHeight = 310.0;
  static const _maxWidth = 600.0;

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
              elevation: 0,
              //leading: const BackButton(),
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: widget.info.icon,
                      height: 100,
                      width: 100,
                      fit: BoxFit.fill,
                    ).clipOval(),
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
                          (type) => TagsBoxes(
                            text: switch (type) {
                              ClubType.tech => "技术",
                              ClubType.acg => "晒你系",
                              ClubType.union => "官方",
                              ClubType.profit => "商业",
                              ClubType.sport => "体育",
                              ClubType.art => "文化",
                              ClubType.game => "游戏",
                              ClubType.unknown => "未知",
                            },
                          ).padding(horizontal: 2),
                        ),
                      ],
                    ),
                  ],
                ).padding(top: kToolbarHeight, bottom: 46),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(46.0),
                child:
                    [
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: widget.info.qq),
                              );
                              if (context.mounted) {
                                showToast(
                                  context: context,
                                  msg: "QQ 号已经复制到剪贴板",
                                );
                              }
                            },
                            child: Ink(
                              height: 46.0,
                              child: Text(
                                "QQ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ).center(),
                            ),
                          ).expanded(),
                          InkWell(
                            onTap: () async {
                              if (widget.info.qqlink.isEmpty) {
                                showToast(context: context, msg: "未提供入群链接");
                              }
                              launchUrlString(widget.info.qqlink);
                            },
                            child: Ink(
                              height: 46.0,
                              child: Text(
                                "邀请链接",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ).center(),
                            ),
                          ).expanded(),
                        ]
                        .toRow(mainAxisAlignment: MainAxisAlignment.spaceAround)
                        .constrained(maxWidth: _maxWidth),
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: [
                  FutureBuilder<String>(
                    future: _content,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return LinearProgressIndicator().padding(bottom: 2);
                      } else {
                        return SizedBox(height: 6);
                      }
                    },
                  ),

                  if (widget.info.pic > 0) ...[
                    ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: widget.info.pic,
                          itemBuilder: (context, index) => CachedNetworkImage(
                            imageUrl: getClubImage(widget.info.code, index),
                            height: 300,
                          ).clipRRect(all: 12).padding(horizontal: 4),
                        )
                        .clipRRect(all: 12)
                        .padding(horizontal: 8)
                        .constrained(height: 300, maxWidth: 600),
                    Divider(color: Colors.transparent),
                  ],
                  FutureBuilder<String>(
                    future: _content,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        try {
                          return SelectionArea(
                                child: HtmlWidget(
                                  snapshot.data ?? '''<p>加载遇到问题</p>''',
                                ).padding(horizontal: 4, bottom: 2),
                              )
                              .padding(horizontal: 8)
                              .constrained(maxWidth: _maxWidth);
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
                ].toColumn(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
