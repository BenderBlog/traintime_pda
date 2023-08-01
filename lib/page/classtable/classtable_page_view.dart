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
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// The [ClassTablePageView] is controlled by [classTableState.controllers.pageControl].
class ClassTablePageView extends StatefulWidget {
  const ClassTablePageView({super.key});

  @override
  State<ClassTablePageView> createState() => _ClassTablePageViewState();
}

class _ClassTablePageViewState extends State<ClassTablePageView> {
  late ClassTableState classTableState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: classTableState.controllers.pageControl,
      onPageChanged: (value) {
        /// When [ClassTableState.controllers.pageControl.animateTo] triggered,
        /// page view will try to refresh the [chosenWeek] everytime the page
        /// view changed into a new page. Because animateTo will load every page
        /// it passed.
        ///
        /// So that's the [isTopRowLocked] is used for. When week choice row is
        /// locked, it will not refresh the [chosenWeek]. And when [chosenWeek]
        /// is equal to the current page, unlock the [isTopRowLocked].
        if (!classTableState.controllers.isTopRowLocked) {
          setState(() {
            classTableState.controllers.chosenWeek = value;
          });
          classTableState.controllers.changeTopRow(value);
        }
        if (classTableState.controllers.chosenWeek == value) {
          classTableState.isTopRowLocked = false;
        }
      },
      itemCount: classTableState.semesterLength,
      itemBuilder: (context, index) => ClassTableView(index: index),
    );
  }
}
