import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/school_card_controller.dart';

class QRCodeWindow extends StatelessWidget {
  const QRCodeWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchoolCardController>(
      builder: (c) => FutureBuilder(
        future: c.qrCode(), // It is important that every QR code is fresh
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Center(
                child: Image.memory(
                  snapshot.requireData,
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("没有数据"),
              );
            } else {
              return const Center(
                child: Text("正在加载"),
              );
            }
          } else {
            return const Center(
              child: Text("正在加载"),
            );
          }
        },
      ),
    );
  }
}
