// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

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
  var loadingPercentage = 0;
  late final WebViewController controller;
  late final WebViewCookieManager webViewCookieManager;

  @override
  void initState() {
    webViewCookieManager = WebViewCookieManager();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          loadingPercentage = progress;
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
      ));

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    List<String> toIterate = List.from(widget.cookieDomain)..add(widget.domain);
    for (var i in toIterate) {
      List<Cookie> cookies =
          await NetworkSession().cookieJar.loadForRequest(Uri.parse(i));
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

    if (mounted) {
      controller.loadRequest(
        Uri.parse(widget.domain),
      );
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        controller.canGoBack().then((value) =>
            value ? controller.goBack() : Navigator.of(context).pop());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
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
        body: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        ),
      ),
    );
  }
}
