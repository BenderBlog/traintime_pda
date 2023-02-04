import 'package:get/get.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_sport/punch_session.dart';

class PunchController extends GetxController {
  bool isGet = false;
  String error = "";
  PunchDataList punch = PunchDataList();

  @override
  void onReady() async {
    updatePunch();
  }

  void updatePunch() async {
    await PunchSession().get().onError((error, stackTrace) {
      isGet = false;
      error = error.toString();
      throw error;
    }).then((value) {
      isGet = true;
      punch = value;
    });
    update();
  }
}
