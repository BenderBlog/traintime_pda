/*
Check whether is in school.

Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

The service is provided by xidian ruisi (ylwind).
*/

import 'package:dio/dio.dart';

Future<bool> isInSchool() async {
  Dio dio = Dio();
  String ip = await dio
      .head("http://202.117.119.3:34898")
      .then((value) => value.headers["ip"]![0])
      .onError((error, stackTrace) {
    return "255.255.255.255";
  });
  bool isInSchool = ip.split('.')[0] == "10";
  return isInSchool;
}

class NotSchoolNetworkException implements Exception {
  final msg = "没有在校园网环境";

  @override
  String toString() => msg;
}
