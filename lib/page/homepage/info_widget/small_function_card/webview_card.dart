import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/page/webview/webview.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewCard extends StatelessWidget {
  const WebViewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MyWebView(
              domain: "http://ids.xidian.edu.cn/authserver/",
            ),
          ),
        );
      },
      child: const SmallFunctionCard(
        icon: Icons.web_asset,
        name: "WebView",
        description: "Test",
      ),
    );
  }
}
