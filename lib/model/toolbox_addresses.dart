// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/widgets.dart';

class WebViewAddresses {
  final String name;
  final String url;
  final String description;
  final IconData iconData;

  const WebViewAddresses({
    required this.name,
    required this.url,
    required this.description,
    required this.iconData,
  });
}
