// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/electricity_controller.dart';
import 'package:watermeter/model/datetime_is_today_extension.dart';
import 'package:watermeter/page/electricity/electricity_window.dart';
import 'package:watermeter/page/homepage/main_page_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

class ElectricityCard extends StatelessWidget {
  const ElectricityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ElectricityController.i.electricityInfoSignal.watch(context);
    return MainPageCard(
      onPressed: () async {
        context.push(ElectricityWindow());
      },
      isLoad: state.isLoading && !state.isRefreshing,
      icon: MingCuteIcons.mgc_flash_line,
      text: FlutterI18n.translate(context, "homepage.electricity_card.title"),
      infoText: DefaultTextStyle(
        style: const TextStyle(fontSize: 20),
        child: state.map(
          data: (value) => Text(
            value.$2.remain.contains(RegExp(r'[0-9]'))
                ? FlutterI18n.translate(
                    context,
                    "homepage.electricity_card.current_electricity",
                    translationParams: {"amount": value.$2.remain},
                  )
                : FlutterI18n.translate(context, value.$2.remain),
          ),
          error: () => Text(
            FlutterI18n.translate(
              context,
              "electricity_status.remain_not_found",
            ),
          ),
          loading: () => Text(
            FlutterI18n.translate(
              context,
              "electricity_status.remain_fetching",
            ),
          ),
        ),
      ),

      bottomText: state.map(
        data: (value) {
          // If not today, it must be cache, so show cache date
          if (!value.$2.fetchDay.isToday) {
            return Text(
              FlutterI18n.translate(
                context,
                "homepage.electricity_card.cache_notice",
                translationParams: {
                  "date": DateFormat(
                    "yyyy-MM-dd HH:mm",
                  ).format(value.$2.fetchDay),
                },
              ).replaceAll("\n", ""),
            );
          }

          if (value.$2.owe.contains(RegExp(r'[0-9]'))) {
            return Text(
              FlutterI18n.translate(
                context,
                "electricity_status.owe_need_pay",
                translationParams: {"due": value.$2.owe},
              ),
              overflow: TextOverflow.ellipsis,
            );
          }
          return Text(
            FlutterI18n.translate(context, value.$2.owe),
            overflow: TextOverflow.ellipsis,
          );
        },
        error: () => Text(
          FlutterI18n.translate(context, "electricity_status.owe_issue"),
        ),
        loading: () => Text(
          FlutterI18n.translate(context, "electricity_status.owe_fetching"),
        ),
      ),
    );
  }
}
