// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:watermeter/controller/sport_controller.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/safe_scroll_padding.dart';
import 'package:watermeter/repository/miscellaneous_session/xidian_sport_session.dart';
import 'package:watermeter/repository/translation_key.dart';

class SportClassWindow extends StatefulWidget {
  const SportClassWindow({super.key});

  @override
  State<SportClassWindow> createState() => _SportClassWindowState();
}

class _SportClassWindowState extends State<SportClassWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<FetchResult<SportClass>> _future = SportController.i.reloadClass();

  Object? _translateError(BuildContext context, Object? error) {
    if (error is SportCredentialMissingException ||
        error is SportCredentialInvalidException) {
      return context.t.resolveKey(error.toString());
    }
    if (error is String) {
      return context.t.resolveKey(error);
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _future = SportController.i.reloadClass();
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
                    dataType: context.t.sport.title,
                    hint:
                        result.cacheHint?.resolve(context.t) ??
                        context.t.common.cacheReasonDefault,
                    placeOfCache: PlaceOfCache.inapp,
                    fetchTime: result.fetchTime,
                  ),
                Builder(
                  builder: (context) {
                    if (toShow.isEmpty) {
                      return EmptyListView(
                        type: EmptyListViewType.singing,
                        text: context.t.sport.emptyClassInfo,
                      );
                    } else {
                      return ListView.separated(
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
                          vertical: 9,
                        ).withSafeBottom(context),
                      );
                    }
                  },
                ).expanded(),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return ReloadWidget(
              function: () => setState(() {
                _future = SportController.i.reloadClass();
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

    String timeWeek = context.t.resolveKey(
      "weekday.${weekList[data.week - 1]}",
    );

    String timePlace = context.t.sport.fromTo(
      start: data.start.toString(),
      stop: data.stop.toString(),
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
