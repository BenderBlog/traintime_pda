import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/page/webview/webview.dart';

class WebViewCard extends StatelessWidget {
  const WebViewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MyWebView(
              cookieDomainList: const ["http://ids.xidian.edu.cn/authserver/"],
              domain: "https://payment.xidian.edu.cn/MNetWorkUI/showPublic",
            ),
          ),
        );
      },
      child: const SmallFunctionCard(
        icon: Icons.payment,
        name: "缴费平台",
        description: "你电费交了吗",
      ),
    );
  }
}
