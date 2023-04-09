/*
Cookie Jar Database.

Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

/// Will be initialized at the beginning of the program.
late PersistCookieJar SportCookieJar;
late PersistCookieJar IDSCookieJar;

Future<bool> isInSchool() async {
  Dio dio = Dio();
  bool isInSchool = await dio
      .get("https://isxdu.ripic.tech/")
      .then((value) => value.data["isxdu"])
      .onError((error, stackTrace) => false);
  return isInSchool;
}
