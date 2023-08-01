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
import 'package:watermeter/page/classtable/class_detail/class_detail_dialog.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_state.dart';
import 'package:watermeter/page/widget.dart';

/// A list of the class info in that period, in case of conflict class.
class ClassDetailList extends StatelessWidget {
  const ClassDetailList({super.key});

  @override
  Widget build(BuildContext context) {
    ClassDetailState classDetailState = ClassDetailState.of(context)!;
    return ListView(
      shrinkWrap: true,
      children: List.generate(
        classDetailState.information.length,
        (i) => ClassDetailDialog(
          classDetail: classDetailState
              .classDetail[classDetailState.information[i].index],
          timeArrangement: classDetailState.information[i],
          infoColor: colorList[classDetailState.information[i].index],
          currentWeek: classDetailState.currentWeek,
        ),
      ),
    );
  }
}
