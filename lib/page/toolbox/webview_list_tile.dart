// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/toolbox_addresses.dart';

class WebViewListTile extends StatelessWidget {
  final WebViewAddresses data;
  const WebViewListTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(data.iconData),
      title: Text(data.name),
      subtitle: Text(data.description),
      onTap: () =>
          launchUrlString(data.url, mode: LaunchMode.externalApplication),
    );
  }
}
