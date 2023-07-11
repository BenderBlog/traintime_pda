import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';

class SchoolCardController extends GetxController {
  SchoolCardSession session = SchoolCardSession();
  late Future<Uint8List> qrcode;
  var money = "".obs;
  List<DateTime?> timeRange = [];
  var getPaid = <PaidRecord>[].obs;
  @override
  void onInit() {
    super.onInit();
    var now = Jiffy.now();
    timeRange = [
      now.startOf(Unit.month).dateTime,
      now.endOf(Unit.month).dateTime,
    ];
  }

  @override
  void onReady() async {
    super.onReady();
    await session.initSession();
    await updateMoney();
  }

  Future<void> refreshPaidRecord() async {
    getPaid.value = await session.getPaidStatus(
      Jiffy.parseFromDateTime(timeRange[0]!).format(pattern: "yyyy-MM-dd"),
      Jiffy.parseFromDateTime(timeRange[1]!).format(pattern: "yyyy-MM-dd"),
    );
    update();
  }

  Future<void> updateMoney() async {
    money.value = await session.getMoney();
  }
}
