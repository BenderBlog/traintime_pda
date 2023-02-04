import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

class ScoreController extends GetxController {
  bool isGet = false;
  String? error;
  List<Score> scores = [];

  @override
  void onReady() async {
    await ScoreFile().get().onError((error, stackTrace) {
      error = error.toString();
      throw error;
    }).then((value) {
      isGet = true;
      scores = value;
    });
    update();
  }
}
