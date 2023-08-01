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
import 'package:watermeter/model/xidian_ids/classtable.dart';

/// A new page to show the class without time arrangement.
///
/// When executing [Navigator.of(context).push()], the page is not mounted under
/// the [ClassTableState] node on the Widget Tree, so I cannot use [ClassTableState.of(context)!].

class NotArrangedClassList extends StatelessWidget {
  /// A list of [ClassDetail] which do not have the time arrangement.
  final List<ClassDetail> notArranged;
  const NotArrangedClassList({
    super.key,
    required this.notArranged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("没有时间安排的科目"),
      ),
      body: ListView.builder(
        itemCount: notArranged.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(notArranged[index].name),
          subtitle: Text(
            "编号: ${notArranged[index].code} | ${notArranged[index].number}\n"
            "老师: ${notArranged[index].teacher ?? "没有数据"}",
          ),
        ),
      ),
    );
  }
}
