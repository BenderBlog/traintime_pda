// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

extension HomeCardPadding on Widget {
  Widget withHomeCardStyle(Color color) {
    return backgroundColor(color).clipRRect(all: 12).padding(all: 4);
  }
}
