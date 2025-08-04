import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:watermeter/page/club_suggestion/club_detail.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/pda_service_session.dart';

class ClubSuggestion extends StatelessWidget {
  const ClubSuggestion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("社团推荐")),
      body: Obx(() {
        switch (clubState.value) {
          case SessionState.fetching:
            return CircularProgressIndicator().center();
          case SessionState.fetched:
            return LayoutBuilder(
              builder: (context, constraints) => MasonryGridView.count(
                shrinkWrap: true,
                itemCount: clubList.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                crossAxisCount: constraints.maxWidth ~/ 280,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                itemBuilder: (context, index) {
                  final data = clubList[index];
                  return [
                    Image.network(
                      getClubAvatar(data.code),
                      errorBuilder: (
                        BuildContext context,
                        Object e,
                        StackTrace? s,
                      ) {
                        log.error("Could not fetch image.", e, s);
                        return const Icon(
                          Icons.face_2,
                          size: 64,
                        );
                      },
                      width: 64,
                      height: 64,
                    ).clipOval(),
                    VerticalDivider(),
                    [
                      [
                        Text(
                          data.title,
                          style: TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).expanded(),
                        data.typeList
                            .map(
                              (type) => Text(
                                switch (type) {
                                  ClubType.tech => "技术",
                                  ClubType.acg => "晒你系",
                                  ClubType.union => "官方",
                                  ClubType.profit => "商业",
                                  ClubType.sport => "体育",
                                  ClubType.art => "文化",
                                  ClubType.unknown => "未知",
                                },
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                              )
                                  .padding(all: 4)
                                  .backgroundColor(
                                      Theme.of(context).colorScheme.primary)
                                  .clipRRect(all: 8)
                                  .padding(left: 4),
                            )
                            .toList()
                            .toRow(),
                      ].toRow(),
                      Text(
                        data.intro,
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                        .expanded(),
                  ]
                      .toRow(mainAxisAlignment: MainAxisAlignment.start)
                      .padding(all: 12)
                      .card(elevation: 0)
                      .gestures(
                        onTap: () => context.push(ClubDetail(info: data)),
                      );
                },
              ),
            );
          case SessionState.error:
            return ReloadWidget(
              function: getClubList,
              errorStatus: "获取数据过程中发生错误",
            );
          case SessionState.none:
            return ReloadWidget(
              function: getClubList,
              errorStatus: "未开始获取数据",
            );
        }
      }),
    );
  }
}
