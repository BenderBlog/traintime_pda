// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';
import 'package:watermeter/generated/l10n.dart';

class SportClassWindow extends StatefulWidget {
  const SportClassWindow({super.key});

  @override
  State<SportClassWindow> createState() => _SportClassWindowState();
}

class _SportClassWindowState extends State<SportClassWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<FetchResult<SportClass>> _future = SportSession().getClass();

  Object? _translateError(BuildContext context, Object? error) {
    if (error is SportCredentialMissingException) {
      return I18n.of(context)!.sportErrorMissingPassword;
    }
    if (error is SportCredentialInvalidException) {
      return I18n.of(context)!.sportErrorCredentialInvalid;
    }
    return error;
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
                    dataType: I18n.of(context)!.sportTitle,
                    hint: _sportCacheHint(context, result.cacheHint),
                    placeOfCache: PlaceOfCache.inapp,
                    fetchTime: result.fetchTime,
                  ),
                if (toShow.isEmpty)
                  EmptyListView(
                    type: EmptyListViewType.singing,
                    text: I18n.of(context)!.sportEmptyClassInfo,
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
    String timeWeek = switch (data.week) {
      1 => I18n.of(context)!.weekdayMonday,
      2 => I18n.of(context)!.weekdayTuesday,
      3 => I18n.of(context)!.weekdayWednesday,
      4 => I18n.of(context)!.weekdayThursday,
      5 => I18n.of(context)!.weekdayFriday,
      6 => I18n.of(context)!.weekdaySaturday,
      7 => I18n.of(context)!.weekdaySunday,
      _ => I18n.of(context)!.weekdayMonday,
    };

    String timePlace = I18n.of(context)!.sportFromTo(data.start.toString(), data.stop.toString());

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

String _sportCacheHint(BuildContext context, Object? hint) {
  if (hint == null) {
    return I18n.of(context)!.cacheReasonDefault;
  }
  return switch (hint) {
    SportCacheHint.missingPassword =>
      I18n.of(context)!.sportCacheHintMissingPassword,
    SportCacheHint.credentialInvalid =>
      I18n.of(context)!.sportCacheHintCredentialInvalid,
    SportCacheHint.maintain =>
      I18n.of(context)!.sportCacheHintMaintain,
    SportCacheHint.loginFailed =>
      I18n.of(context)!.sportCacheHintLoginFailed,
    SportCacheHint.queryFailed =>
      I18n.of(context)!.sportCacheHintQueryFailed,
    SportCacheHint.networkFailed =>
      I18n.of(context)!.sportCacheHintNetwork,
    SportCacheHint.unknownError =>
      I18n.of(context)!.sportCacheHintUnknown,
    _ => I18n.of(context)!.cacheReasonDefault,
  };
}
