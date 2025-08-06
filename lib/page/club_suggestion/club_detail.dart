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

  static const _expandedHeight = 300.0;

  bool _isShrunk = false;

  void _scrollListener() {
    final shouldBeShrunk = _scrollController.hasClients &&
        _scrollController.offset > (_expandedHeight - kToolbarHeight);

    if (shouldBeShrunk != _isShrunk) {
      setState(() {
        _isShrunk = shouldBeShrunk;
      });
    }
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
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedHeight,
            centerTitle: false,
            pinned: true,
            title: Visibility(
              visible: _isShrunk,
              child: Text(widget.info.title),
            ),
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
                  ).clipOval(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.info.title,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.info.intro,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.info.typeList
                        .map<String>((type) => switch (type) {
                              ClubType.tech => "技术",
                              ClubType.acg => "晒你系",
                              ClubType.union => "官方",
                              ClubType.profit => "商业",
                              ClubType.sport => "体育",
                              ClubType.art => "文化",
                              ClubType.unknown => "未知",
                            })
                        .join("; "),
                    //style: TextStyle(fontSize: 14),
                  ),
                ],
              ).padding(top: kToolbarHeight),
            ),
          ),
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Material(
                elevation: 7,
                child: [
                  [
                    TextButton(
                      child: Text("QQ"),
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.info.qq));
                        if (context.mounted) {
                          showToast(context: context, msg: "QQ 号已经复制到剪贴板");
                        }
                      },
                    ),
                    TextButton(
                      child: Text("邀请链接"),
                      onPressed: () async {
                        if (widget.info.qqlink.isEmpty) {
                          showToast(context: context, msg: "未提供入群链接");
                        }
                        launchUrlString(widget.info.qqlink);
                      },
                    )
                  ].toRow(mainAxisAlignment: MainAxisAlignment.spaceAround),
                  Divider(color: Colors.transparent),
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
                    ).clipRRect(all: 12).constrained(height: 300),
                    Divider(color: Colors.transparent),
                  ],
                  SelectionArea(
                      child: FutureBuilder<String>(
                    future: _content,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        try {
                          return HtmlWidget(
                            snapshot.data ?? '''<p>加载遇到问题</p>''',
                          ).padding(horizontal: 4);
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
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )),
                ].toColumn(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
