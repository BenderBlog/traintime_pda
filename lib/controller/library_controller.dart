import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class LibraryController extends GetxController {
  bool isGet = false;
  String? error;
  List<BorrowData> borrowList = [];

  @override
  void onReady() {
    super.onReady();
    LibrarySession().initSession();
    getBorrowList();
  }

  void getBorrowList() async {
    borrowList.addAll(await LibrarySession().getBorrowList());
    update();
  }
}
