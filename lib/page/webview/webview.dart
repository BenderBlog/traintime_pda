import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:watermeter/repository/network_session.dart';

const htmlString = '''
<!DOCTYPE html>
<head>
<title>webview demo | IAM17</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, 
  maximum-scale=1.0, user-scalable=no,viewport-fit=cover" />
<style>
*{
  margin:0;
  padding:0;
}
body{
   background:#BBDFFC;  
   display:flex;
   justify-content:center;
   align-items:center;
   height:100px;
   color:#C45F84;
   font-size:20px;
}
</style>
</head>
<html>
<body>
<div >大家好，我是 17</div>
</body>
</html>
''';

class MyWebView extends StatefulWidget {
  final String domain;
  const MyWebView({
    super.key,
    required this.domain,
  });

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late final WebViewCookieManager webViewCookieManager;
  late final WebViewController controller;
  double height = 0;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    List<Cookie> cookies = await NetworkSession().cookieJar.loadForRequest(
          Uri.parse("http://ids.xidian.edu.cn/authserver"),
        );

    for (var element in cookies) {
      log("webview: ${element.name} = ${element.value} ${element.domain} ${element.secure}");
    }
    webViewCookieManager = WebViewCookieManager();

    for (var element in cookies) {
      webViewCookieManager.setCookie(
        WebViewCookie(
          name: element.name,
          value: element.value,
          domain: widget.domain,
        ),
      );
    }

    if (mounted) {
      controller.loadRequest(
        Uri.parse(
          "https://payment.xidian.edu.cn/MNetWorkUI/showPublic",
        ),
      );
      log("showld log page");
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Webview"),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
