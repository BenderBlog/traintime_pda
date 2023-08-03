import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebView extends StatefulWidget {
  final String domain;
  final String name;
  final List<String> cookieDomain;
  WebView({
    super.key,
    required this.name,
    required this.domain,
    List<String>? cookieDomainList,
  }) : cookieDomain = cookieDomainList ?? [];

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController controller;
  late final WebViewCookieManager webViewCookieManager;

  @override
  void initState() {
    webViewCookieManager = WebViewCookieManager();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    List<String> toIterate = List.from(widget.cookieDomain)..add(widget.domain);
    for (var i in toIterate) {
      List<Cookie> cookies =
          await NetworkSession().cookieJar.loadForRequest(Uri.parse(i));

      for (var element in cookies) {
        developer.log(
          "webview: ${element.name} = ${element.value} ${widget.domain}${element.domain ?? ""}",
          name: "MyWebView",
        );

        for (var element in cookies) {
          webViewCookieManager.setCookie(
            WebViewCookie(
              name: element.name,
              value: element.value,
              domain: "${widget.domain}${element.domain ?? ""}",
            ),
          );
        }
      }
    }

    if (mounted) {
      controller.loadRequest(
        Uri.parse(widget.domain),
      );
      developer.log(
        "showld log page ${widget.domain}",
        name: "MyWebView",
      );
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            onPressed: () {
              launchUrlString(
                widget.domain,
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.link),
          ),
        ],
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
