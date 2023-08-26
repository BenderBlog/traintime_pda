// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/widget.dart';

class NoArrangedInfo extends StatelessWidget {
  final List<ToBeArranged> list;
  const NoArrangedInfo({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("目前无安排考试的科目"),
      ),
      body: dataList<Card, Card>(
        List.generate(
          list.length,
          (index) => Card(
            child: ListTile(
              title: Text(list[index].subject),
              subtitle: Text(
                "编号: ${list[index].id}\n"
                "老师: ${list[index].teacher ?? "没有数据"}",
              ),
            ),
          ),
        ),
        (toUse) => toUse,
      ),
    );
  }
}
