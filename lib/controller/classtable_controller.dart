import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';

class ClassTableController extends GetxController {
  bool isGet = false;
  String? error;
  ClassTable classTable = ClassTable();

  @override
  void onReady() async {
    await ClassTableFile().get().onError((error, stackTrace) {
      error = error.toString();
      throw error;
    }).then((value) {
      isGet = true;
      classTable.update(value);
    });
    update();
  }
}
