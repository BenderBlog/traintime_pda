//import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/paid_record.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';

class SchoolCardController extends GetxController {
  bool isGet = false;
  String? error;

  SchoolCardSession session = SchoolCardSession();
  // late Future<Uint8List> qrcode;
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
    try {
      super.onReady();
      await session.initSession();
      await updateMoney();
    } on DioException catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ScoreController",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } catch (e, s) {
      developer.log(
        "Other exception: $e\nStack: $s",
        name: "ScoreController",
      );
      error = "未知错误，感兴趣的话，请接到电脑 adb 查看日志。";
    }
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
