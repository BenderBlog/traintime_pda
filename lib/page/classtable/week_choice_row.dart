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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// A row shows a series of buttons about the classtable's index.
///
/// [WeekChoiceRow] is at the top of the classtable. It contains a series of
/// buttons which shows the week index, as well as an overview in a 5x5 dot gridview.
///
/// When user click on the button, the pageview will show the class table of the
/// week the button suggested.
class WeekChoiceRow extends StatefulWidget {
  const WeekChoiceRow({super.key});

  @override
  State<WeekChoiceRow> createState() => _WeekChoiceRowState();
}

class _WeekChoiceRowState extends State<WeekChoiceRow> {
  late ClassTableState classTableState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Init of the InheritedWidget must inside didChangeDependencies
    classTableState = ClassTableState.of(context)!;

    /// When [ClassTableState.controller.isTopRowLocked] unlocked,
    /// refresh the state of this, in order to show the nearly chosen week.
    classTableState.controllers.addListener(() {
      setState(() {});
    });
  }

  /// The dot of the overview, [isOccupied] is used to identify the opacity of the dot.
  Widget dot({required bool isOccupied}) {
    double opacity = isOccupied ? 1 : 0.25;
    return ClipOval(
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(opacity),
      ),
    );
  }

  /// [buttonInformaion] shows the botton's [index] and the overview.
  ///
  /// A [index] is required to render the botton for the week.
  Widget buttonInformaion({required int index}) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AutoSizeText(
            "第${index + 1}周",
            style: TextStyle(
              fontWeight: index == classTableState.currentWeek
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            maxLines: 1,
            group: AutoSizeGroup(),
          ),

          /// These code are used to render the overview of the week,
          /// as long as the height of the page is over 500.
          if (MediaQuery.sizeOf(context).height >= 500)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6,4,6,2,),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (int i = 0; i < 10; i += 2)
                      for (int day = 0; day < 5; ++day)
                        dot(
                          isOccupied: !classTableState.pretendLayout[index][day]
                                  [i]
                              .contains(-1),
                        )
                  ],
                ),
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      /// Related to the overview of the week.
      height: MediaQuery.sizeOf(context).height >= 500
          ? topRowHeightBig
          : topRowHeightSmall,
      child: Container(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 4,
        ),
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          controller: classTableState.controllers.rowControl,
          scrollDirection: Axis.horizontal,
          itemCount: classTableState.semesterLength,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: weekButtonHorizontalPadding,
              ),
              child: SizedBox(
                width: weekButtonWidth,
                child: Card(
                  color: Theme.of(context).primaryColor.withOpacity(
                        classTableState.controllers.chosenWeek == index
                            ? 0.3
                            : 0.0,
                      ),
                  elevation: 0.0,
                  child: InkWell(
                    /// The following themes are the same as the Material 3 Card Radius.
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    splashColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                    onTap: () {
                      /// The following sequence is used when triggering changing page.
                      ///  * topRowLocked
                      ///  * change the chosen week
                      ///  * trigger pageview controller [pageControl] change, as well as
                      ///  * change the [WeekChoiceRow]

                      classTableState.controllers.isTopRowLocked = true;
                      setState(() {
                        classTableState.controllers.chosenWeek = index;
                        classTableState.controllers.pageControl.animateToPage(
                          index,
                          curve: Curves.linear,
                          duration:
                              const Duration(milliseconds: changePageTime),
                        );
                        classTableState.controllers.changeTopRow(index);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: buttonInformaion(index: index),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
