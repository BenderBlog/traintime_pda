// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/page/empty_classroom/empty_classroom_search_window.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/xidian_ids/jiaowu_service_session.dart';

class EmptyClassroomWindow extends StatefulWidget {
  const EmptyClassroomWindow({super.key});

  @override
  State<EmptyClassroomWindow> createState() => _EmptyClassroomWindowState();
}

class _EmptyClassroomWindowState extends State<EmptyClassroomWindow> {
  late Future<List<EmptyClassroomPlace>> places;

  @override
  void initState() {
    super.initState();
    places = JiaowuServiceSession().getBuildingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("空闲教室")),
      body: FutureBuilder(
        future: places,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return ReloadWidget(
                errorStatus: snapshot.error,
                function: () => setState(() {
                  places = JiaowuServiceSession().getBuildingList();
                }),
              );
            } else {
              return EmptyClassroomSearchWindow(
                places: snapshot.data!,
              );
            }
          } else {
            return const CircularProgressIndicator().center();
          }
        },
      ),
    );
  }
}
