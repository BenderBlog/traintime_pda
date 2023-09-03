// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

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
  String? situation;
  int allTime = -1;
  int validTime = -1;
  double score = -1;
  List<PunchData> all = [];
  List<PunchData> valid = [];
}
