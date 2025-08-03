import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:watermeter/repository/pda_service_session.dart';

class ClubDetail extends StatelessWidget {
  final ClubInfo info;
  const ClubDetail({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info.title),
      ),
      body: ListView(children: [
        [
          CachedNetworkImage(
            imageUrl: getClubAvatar(info.code),
            width: 96,
            height: 96,
          ).clipOval(),
          VerticalDivider(),
          [
            Text(info.title),
            Text(info.intro),
            Text("QQ 号：${info.qq}"),
            info.typeList
                .map(
                  (type) => Text(switch (type) {
                    ClubType.tech => "技术",
                    ClubType.acg => "晒你系",
                    ClubType.union => "官方",
                    ClubType.profit => "商业",
                    ClubType.sport => "体育",
                    ClubType.art => "文化",
                    ClubType.unknown => "未知",
                  }),
                )
                .toList()
                .toRow(),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.center)
            .padding(vertical: 8),
        if (info.pic > 0)
          ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: info.pic,
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: getClubImage(info.code, index),
            ).clipRRect(all: 12).padding(horizontal: 4),
          ).constrained(height: 200),
        Text(info.description).padding(vertical: 8),
      ]).constrained(maxWidth: 600).center(),
    );
  }
}
