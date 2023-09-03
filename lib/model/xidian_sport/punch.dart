// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class PunchData {
  String machineName;
  String weekNum;
  Jiffy time;
  String state;

  PunchData(
    this.machineName,
    this.weekNum,
    this.time,
    this.state,
  );
}

class PunchDataList {
  RxString situation = "".obs;
  RxInt allTime = (-1).obs;
  RxInt validTime = (-1).obs;
  RxDouble score = (-1.0).obs;
  RxList<PunchData> all = <PunchData>[].obs;
  RxList<PunchData> valid = <PunchData>[].obs;

  void reset() {
    situation = "正在获取".obs;
    allTime = (-1).obs;
    validTime = (-1).obs;
    score = (-1.0).obs;
    all.clear();
    valid.clear();
  }
}
