// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/toolbox_addresses.dart';
import 'package:watermeter/page/homepage/toolbox/small_function_card.dart';
import 'package:watermeter/page/homepage/toolbox/webview.dart';

class WebViewCard extends StatelessWidget {
  final WebViewAddresses data;
  const WebViewCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard.fromSchoolAddress(
      data: data,
      onTap: () async {
        if (!Platform.isAndroid) {
          launchUrlString(data.url);
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
