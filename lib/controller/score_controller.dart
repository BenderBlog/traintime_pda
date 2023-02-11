import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

class ScoreController extends GetxController {
  bool isGet = false;
  String? error;
  List<Score> scores = [];

  @override
  void onReady() async {
    get();
    update();
  }

  Future<void> get() async {
    isGet = false;
    error = null;
    try {
      scores = await ScoreFile().get();
      isGet = true;
      error = null;
    } on DioError catch (e, s) {
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
    update();
  }
}
