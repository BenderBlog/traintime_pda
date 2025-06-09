// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:watermeter/repository/logger.dart';

void showToast({
  required BuildContext context,
  required String msg,
}) {
  if (Platform.isAndroid || Platform.isIOS) {
    Fluttertoast.showToast(msg: msg);
  } else {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
      ));
    } catch (e) {
      log.error("Show snackbar failed, ignore it!", e);
    }
  }
}
