// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/toolbox_addresses.dart';
import 'package:watermeter/page/toolbox/webview.dart';

class WebViewListTile extends StatelessWidget {
  final WebViewAddresses data;
  const WebViewListTile({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(data.iconData),
      title: Text(data.name),
      subtitle: Text(data.description),
      onTap: () async {
        if (!Platform.isAndroid) {
          launchUrlString(
            data.url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WebView(
                name: data.name,
                cookieDomainList: const [
                  "http://ids.xidian.edu.cn/authserver/"
                ],
                domain: data.url,
              ),
            ),
          );
        }
      },
    );
  }
}
