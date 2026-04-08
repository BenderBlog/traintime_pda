// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
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

  late Future<FetchResult<SportClass>> _future;

  Object? _translateError(BuildContext context, Object? error) {
    if (error is SportCredentialMissingException ||
        error is SportCredentialInvalidException) {
      return FlutterI18n.translate(context, error.toString());
    }
    if (error is String) {
      return FlutterI18n.translate(context, error);
    }
    return error;
  }

  @override
  void initState() {
    super.initState();
    _future = SportSession().getClass();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _future = SportSession().getClass();
        });
      },
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final result = snapshot.data!;
            List<Widget> toShow = result.data
                .map((element) => SportClassCard(data: element))
                .toList();

            return Column(
              children: [
                if (result.isCache)
                  CacheAlerter(
                    hint:
                        (result.hintKey != null
                            ? FlutterI18n.translate(context, result.hintKey!)
                            : null) ??
                        FlutterI18n.translate(
                          context,
                          "inapp_cache_hint",
                          translationParams: {
                            "datetime": result.fetchTime.toString(),
                          },
                        ),
                  ),
                if (toShow.isEmpty)
                  EmptyListView(
                    type: EmptyListViewType.singing,
                    text: FlutterI18n.translate(
                      context,
                      "sport.empty_class_info",
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: toShow.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: sheetMaxWidth,
                            ),
                            child: toShow[index],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.5,
                        vertical: 9.0,
                      ),
                    ),
                  ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return ReloadWidget(
              function: () => setState(() {
                _future = SportSession().getClass();
              }),
              errorStatus: _translateError(context, snapshot.error),
              stackTrace: snapshot.stackTrace,
            ).center();
          } else {
            return const CircularProgressIndicator().center();
          }
        },
      ),
    );
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
