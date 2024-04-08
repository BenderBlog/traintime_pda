// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

void showToast({required String msg}) {
  if (Platform.isAndroid || Platform.isIOS) {
    Fluttertoast.showToast(msg: msg);
  } else {
    Get.snackbar("软件内信息", msg);
  }
}
