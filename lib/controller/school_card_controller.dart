import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';

class SchoolCardController extends GetxController {
  SchoolCardSession session = SchoolCardSession();
  var money = "".obs;

  String startDay = "";
  String endDay = "";
  @override
  void onReady() async {
    super.onReady();
    await session.initSession();
    await updateMoney();
  }

  Future<Uint8List> qrCode() async => await session.getQRCode();

  Future<void> updateMoney() async {
    money.value = await session.getMoney();
  }
}
