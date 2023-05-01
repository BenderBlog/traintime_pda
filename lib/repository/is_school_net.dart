/*
Check whether is in school.

Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

The binary is provided by ylwind.
*/

import 'package:dio/dio.dart';

Future<bool> isInSchool() async {
  Dio dio = Dio();
  bool isInSchool = await dio
      .get("https://server.superbart.xyz/isxdu/")
      .then((value) => value.data["isxdu"])
      .onError((error, stackTrace) => false);
  return isInSchool;
}

class NotSchoolNetworkException implements Exception {
  final msg = "没有在校园网环境";

  @override
  String toString() => msg;
}
