/*
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Additionaly, for this file,

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// The index row of the class table, shows the index of the day and the week.
class ClassTableDateRow extends StatelessWidget {
  final List<DateTime> dateList = [];
  ClassTableDateRow({super.key, required DateTime firstDay}) {
    /// Here, we get the first day of the week, and generate the date row.
    dateList.addAll(List.generate(7, (i) => firstDay.add(Duration(days: i))));
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.sizeOf(context);
    return Container(
      /// This will detertime the height of the row, also the way week info and
      /// day shows.
      height: mediaQuerySize.width / mediaQuerySize.height >= 1.20
          ? midRowHeightHorizontal
          : midRowHeightVertical,
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.grey.shade200.withOpacity(0.75),
      child: Row(
        children: List.generate(8, (index) {
          if (index > 0) {
            return WeekInfomation(time: dateList[index - 1]);
          } else {
            return SizedBox(
              width: leftRow,
              child: Center(
                child: AutoSizeText(
                  "课次",
                  textAlign: TextAlign.center,
                  group: AutoSizeGroup(),
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

/// The week index info, shows the day and the week.
class WeekInfomation extends StatelessWidget {
  final DateTime time;
  const WeekInfomation({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    bool isToday =
        (time.month == DateTime.now().month && time.day == DateTime.now().day);
    Size mediaQuerySize = MediaQuery.of(context).size;
    bool isHorizontal() => mediaQuerySize.width / mediaQuerySize.height > 1;
    var list = [
      AutoSizeText(
        weekList[time.weekday - 1],
        group: AutoSizeGroup(),
        textScaleFactor: 1.0,
        style: TextStyle(
          //fontSize: 14,
          color: isToday ? Colors.lightBlue : Colors.black87,
        ),
      ),
      isHorizontal() ? const SizedBox(width: 5) : const SizedBox(height: 5),
      AutoSizeText(
        "${time.month}/${time.day}",
        group: AutoSizeGroup(),
        textScaleFactor: isHorizontal() ? 1.0 : 0.8,
        style: TextStyle(
          color: isToday ? Colors.lightBlue : Colors.black87,
        ),
      ),
    ];
    return Container(
      width: (mediaQuerySize.width - leftRow) / 7,

      /// Color may determine today.
      color: isToday ? const Color(0x00f7f7f7) : Colors.transparent,

      /// Row and column are divided with:
      /// [mediaQuerySize.width / mediaQuerySize.height >= 1.20]
      child: mediaQuerySize.width / mediaQuerySize.height >= 1.20
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: list,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: list,
            ),
    );
  }
}
