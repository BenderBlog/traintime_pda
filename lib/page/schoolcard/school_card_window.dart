import 'package:flutter/material.dart';
import 'package:watermeter/page/schoolcard/qr_code_window.dart';
import 'package:watermeter/page/schoolcard/card_log_window.dart';

class SchoolCardWindow extends StatelessWidget {
  const SchoolCardWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("校园卡信息"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                //icon: Icon(Icons.edit),
                text: "查询流水",
              ),
              Tab(
                text: "二维码付款",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CardLogWindow(),
            QRCodeWindow(),
          ],
        ),
      ),
    );
  }
}
