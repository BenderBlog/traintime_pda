import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:styled_widget/styled_widget.dart';
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
  late Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = getClubArticle(widget.info.code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.info.title),
      ),
      body: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          children: [
            SizedBox(height: 8),
            [
              [
                CachedNetworkImage(
                  imageUrl: getClubAvatar(widget.info.code),
                  width: 96,
                  height: 96,
                ).clipOval(),
                SizedBox(width: 12),
                [
                  Text(
                    widget.info.title,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "分类：${widget.info.typeList.map<String>((type) => switch (type) {
                          ClubType.tech => "技术",
                          ClubType.acg => "晒你系",
                          ClubType.union => "官方",
                          ClubType.profit => "商业",
                          ClubType.sport => "体育",
                          ClubType.art => "文化",
                          ClubType.unknown => "未知",
                        }).join("; ")}",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    widget.info.intro,
                    style: TextStyle(fontSize: 14),
                  ),
                ]
                    .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                    .expanded(),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              Text(widget.info.description),
              [
                SelectionArea(
                  child: Text(
                    "QQ: ${widget.info.qq}",
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.copy,
                  size: 14,
                ).gestures(onTap: () async {
                  await Clipboard.setData(ClipboardData(text: widget.info.qq));
                  if (context.mounted) {
                    showToast(context: context, msg: "QQ 号已经复制到剪贴板");
                  }
                }),
              ].toRow()
            ]
                .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                .padding(all: 8)
                .card(elevation: 0),
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
          ]).constrained(maxWidth: 600).center(),
    );
  }
}
