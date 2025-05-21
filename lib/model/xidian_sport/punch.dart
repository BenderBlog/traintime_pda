// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
/*
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class PunchData {
  String machineName;
  String weekNum;
  Jiffy time;
  String stateStr;

  String get state {
    if (stateStr.contains("成功")) {
      return stateStr.length == 4 ? stateStr : "成功：${stateStr.substring(18)}";
    } else if (stateStr.contains("锻炼间隔需30分钟以上")) {
      return stateStr.replaceAll("锻炼间隔需30分钟以上", "");
    } else {
      return stateStr;
    }
  }

  PunchData(
    this.machineName,
    this.weekNum,
    this.time,
    this.stateStr,
  );
}

class PunchDataList {
  RxBool isLoad = true.obs;
  RxString situation = "".obs;
  RxInt allTime = (-1).obs;
  RxInt validTime = (-1).obs;
  RxDouble score = (-1.0).obs;
  RxList<PunchData> all = <PunchData>[].obs;
  RxList<PunchData> valid = <PunchData>[].obs;

  void reset() {
    isLoad.value = true;
    situation = "正在获取".obs;
    allTime = (-1).obs;
    validTime = (-1).obs;
    score = (-1.0).obs;
    all.clear();
    valid.clear();
  }
}
*/
