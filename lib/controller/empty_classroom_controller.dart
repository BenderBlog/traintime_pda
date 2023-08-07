// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ehall/empty_classroom_session.dart';

class EmptyClassroomController extends GetxController {
  late List<EmptyClassroomPlace> places;
  EmptyClassroomSession session = EmptyClassroomSession();
  String semesterCode =
      preference.getString(preference.Preference.currentSemester);

  RxBool isLoad = false.obs;
  RxBool isError = false.obs;
  RxList<EmptyClassroomData> data = <EmptyClassroomData>[].obs;

  late Rx<EmptyClassroomPlace> chosen;
  RxString searchParameter = "".obs;
  Rx<DateTime> time = DateTime.now().obs;

  @override
  void onReady() async {
    super.onReady();
    places = await session.getBuildingList();
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
  }

  void updateData() async {
    isLoad.value = true;
    isError.value = false;
    data.clear();
    try {
      data.addAll(await session.searchData(
        buildingCode: chosen.value.code,
        date: Jiffy.parseFromDateTime(time.value).format(pattern: "yyyy-MM-dd"),
        semesterRange: semesterCode.substring(0, 9),
        semesterPart: semesterCode[semesterCode.length - 1],
        searchParameter: searchParameter.value,
      ));
    } catch (e) {
      isError.value = true;
    }
    isLoad.value = false;
  }
}
