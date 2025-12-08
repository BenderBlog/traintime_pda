// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class SportClassWindow extends StatefulWidget {
  const SportClassWindow({super.key});

  @override
  State<SportClassWindow> createState() => _SportClassWindowState();
}

class _SportClassWindowState extends State<SportClassWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (sportClass.value.items.isEmpty) {
      SportSession().getClass();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        await SportSession().getClass();
      },
      child: Obx(() {
        if (sportClass.value.situation == null) {
          return sportClass.value.items.isNotEmpty
              ? DataList<Widget>(
                  list: sportClass.value.items
                      .map((element) => SportClassCard(data: element))
                      .toList(),
                  initFormula: (toUse) => toUse,
                )
              : EmptyListView(
                  type: EmptyListViewType.singing,
                  text: FlutterI18n.translate(
                    context,
                    "sport.empty_class_info",
                  ),
                );
        } else if (sportClass.value.situation == "sport.situation_fetching") {
          return const CircularProgressIndicator().center();
        } else {
          return ReloadWidget(
            function: () => SportSession().getClass(),
            errorStatus: sportClass.value.situation != null
                ? FlutterI18n.translate(
                    context,
                    "sport.situation_error",
                    translationParams: {
                      "situation": FlutterI18n.translate(
                        context,
                        sportClass.value.situation ?? "",
                      ),
                    },
                  )
                : null,
          ).center();
        }
      }),
    );

    // EasyRefresh(
    //   controller: _controller,
    //   clipBehavior: Clip.none,
    //   header: const MaterialHeader(
    //     clamping: true,
    //     showBezierBackground: false,
    //     bezierBackgroundAnimation: false,
    //     bezierBackgroundBounce: false,
    //     springRebound: false,
    //   ),
    //   onRefresh:
    //   refreshOnStart: true,
    //   child: Obx(() {
    //   }),
    // );
  }
}

class SportClassCard extends StatelessWidget {
  final SportClassItem data;
  const SportClassCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<String> weekList = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    String timeWeek = FlutterI18n.translate(
      context,
      "weekday.${weekList[data.week - 1]}",
    );

    String timePlace = FlutterI18n.translate(
      context,
      "sport.from_to",
      translationParams: {
        "start": data.start.toString(),
        "stop": data.stop.toString(),
      },
    );

    return ReXCard(
      title: Text(data.termToShow),
      remaining: [
        if (data.score.contains(RegExp(r'[0-9]'))) ReXCardRemaining(data.score),
      ],
      bottomRow: [
        InformationWithIcon(
          icon: Icons.access_time_filled_outlined,
          text: "$timeWeek $timePlace",
        ),
        [
          InformationWithIcon(
            icon: Icons.person,
            text: data.teacher,
          ).flexible(),
          InformationWithIcon(icon: Icons.stadium, text: data.place).flexible(),
        ].toRow(),
      ].toColumn(),
    );
  }
}
