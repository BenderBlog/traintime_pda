import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_sport/punch_session.dart';

class PunchController extends GetxController {
  String? error;
  bool isGet = false;
  PunchDataList punch = PunchDataList();

  @override
  void onReady() async {
    await updatePunch();
    update();
  }

  Future<void> updatePunch() async {
    isGet = false;
    error = null;
    try {
      developer.log(
        "Ready to update Punch data",
        name: "PunchController",
      );
      punch = await PunchSession().get();
      isGet = true;
      error = null;
    } on DioError catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "PunchController",
      );
      error = "网络错误，可能是没联网，可能是体适能服务器可以吃了:-P";
    } on String catch (e, s) {
      developer.log(
        "PunchSession exception: $e\nStack: $s",
        name: "PunchController",
      );
      error = "来自 PunchSession 的错误：$e:-P";
    } catch (e, s) {
      developer.log(
        "Other exception: $e\nStack: $s",
        name: "PunchController",
      );
      error = "未知错误，感兴趣的话，请接到电脑 adb 查看日志。";
    }
    update();
  }
}
