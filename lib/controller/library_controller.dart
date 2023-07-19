import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class LibraryController extends GetxController {
  bool isGet = false;
  String? error;
  List<BorrowData> borrowList = [];

  var searchList = <BookInfo>[].obs;
  var search = "".obs;
  int page = 1;
  bool noMore = false;

  int get dued => borrowList.where((element) => element.lendDay < 0).length;
  int get notDued => borrowList.where((element) => element.lendDay >= 0).length;

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

  @override
  void onInit() {
    /// Monitor its change.
    ever(search, (value) {
      searchList.clear();
      page = 1;
      noMore = false;
    });
    super.onInit();
  }

  Future<void> searchBook() async {
    if (!noMore) {
      List<BookInfo> get =
          await LibrarySession().searchBook(search.value, page);
      if (get.isEmpty) {
        noMore = true;
      } else {
        searchList.addAll(get);
        page++;
      }
    }
  }

  Future<List<BookLocation>> getLocation(BookInfo toUse) =>
      LibrarySession().getBookLocation(toUse);
}
