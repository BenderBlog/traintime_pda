// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/repository/logger.dart';

extension OnPopScope on Widget {
  Widget onPopScope({required void Function() onWillPop}) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool mustbe) {
        log.i("pop");
        onWillPop();
      },
      child: this,
    );
  }
}
