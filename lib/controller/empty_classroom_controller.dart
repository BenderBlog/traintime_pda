// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/repository/xidian_ids/jiaowu_service_session.dart';

class EmptyClassroomController extends GetxController {
  List<EmptyClassroomPlace> places = [];
  JiaowuServiceSession session = JiaowuServiceSession();

  RxBool isLoad = true.obs;
  RxBool isError = false.obs;
  RxList<EmptyClassroomData> data = <EmptyClassroomData>[].obs;

  late Rx<EmptyClassroomPlace> chosen;
  RxString searchParameter = "".obs;
  Rx<DateTime> time = DateTime.now().obs;

  @override
  void onReady() async {
    places.addAll(await session.getBuildingList());
    chosen = places.first.obs;
    updateData();

    /// Monitor its change.
    ever(chosen, (value) {
      searchParameter.value = "";
      updateData();
    });
    ever(time, (value) {
      updateData();
    });
    super.onReady();
  }

  void updateData() async {
    isLoad.value = true;
    isError.value = false;
    data.clear();
    try {
      data.addAll(await session.searchEmptyClassroomData(
        buildingCode: chosen.value.code,
        date: Jiffy.parseFromDateTime(time.value).format(pattern: "yyyy-MM-dd"),
      ));
    } catch (e) {
      isError.value = true;
    }
    isLoad.value = false;
  }
}
