// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:styled_widget/styled_widget.dart';

class ClassAddWindow extends StatelessWidget {
  const ClassAddWindow({super.key});

  Widget weekDoc({required int index}) {
    bool isOccupied = true;
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          //color: isOccupied ? infoColor.shade200 : null,
          borderRadius: const BorderRadius.all(Radius.circular(100.0)),
          //border: index == currentWeek
          //    ? Border.all(width: 2, color: infoColor)
          //    : null,
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: TextStyle(
                color: // isOccupied ?
                    Colors.purple.shade900
                //: infoColor.shade400.withOpacity(0.8),
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加课程"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("保存"),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.person),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.place),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.schedule),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: 1,
                items: const <DropdownMenuItem<int>>[
                  DropdownMenuItem<int>(value: 1, child: Text("周一")),
                  DropdownMenuItem<int>(value: 2, child: Text("周二")),
                  DropdownMenuItem<int>(value: 3, child: Text("周三")),
                  DropdownMenuItem<int>(value: 4, child: Text("周四")),
                  DropdownMenuItem<int>(value: 5, child: Text("周五")),
                  DropdownMenuItem<int>(value: 6, child: Text("周六")),
                  DropdownMenuItem<int>(value: 7, child: Text("周日")),
                ],
                onChanged: (int? a) {},
              ),
              const Text("从第 "),
              DropdownButton<int>(
                value: 1,
                items: List<DropdownMenuItem<int>>.generate(
                  10,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(
                      "${index + 1}",
                    ),
                  ),
                ),
                onChanged: (int? a) {},
              ),
              const Text("节课到 "),
              DropdownButton<int>(
                value: 1,
                items: List<DropdownMenuItem<int>>.generate(
                  10,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(
                      "${index + 1}",
                    ),
                  ),
                ),
                onChanged: (int? a) {},
              ),
              const Text("节课"),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_month),
              const SizedBox(width: 8),
              Expanded(
                child: GridView.extent(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  maxCrossAxisExtent: 30,
                  children: List.generate(
                    20,
                    (index) => weekDoc(index: index),
                  ),
                ),
              ),
            ],
          ),
        ],
      ).padding(horizontal: 20),
    );
  }
}
