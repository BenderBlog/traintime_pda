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
import 'package:watermeter/model/xidian_ids/classtable.dart' as model;
import 'package:watermeter/page/classtable/class_detail/class_detail_list.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail_state.dart';

/// The class info of the period. This is an entry.
class ClassDetail extends StatelessWidget {
  final int currentWeek;
  final List<model.TimeArrangement> information;
  final List<model.ClassDetail> classDetail;
  const ClassDetail({
    super.key,
    required this.currentWeek,
    required this.information,
    required this.classDetail,
  });

  @override
  Widget build(BuildContext context) {
    return ClassDetailState(
      currentWeek: currentWeek,
      information: information,
      classDetail: classDetail,
      child: const ClassDetailList(),
    );
  }
}
