import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/page/library/book_detail_card.dart';
import 'package:watermeter/page/library/book_info_card.dart';

class QueryBookWindow extends StatefulWidget {
  const QueryBookWindow({super.key});

  @override
  State<QueryBookWindow> createState() => _QueryBookWindowState();
}

class _QueryBookWindowState extends State<QueryBookWindow>
    with AutomaticKeepAliveClientMixin {
  final LibraryController c = Get.put(LibraryController());

  @override
  bool get wantKeepAlive => true;

  late final PageController _pageController;
  late EasyRefreshController _controller;
  late TextEditingController text;

  @override
  void initState() {
    _pageController = PageController();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    text = TextEditingController.fromValue(
      TextEditingValue(text: c.search.value),
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: TextFormField(
          controller: text,
          decoration: const InputDecoration(
            filled: true,
            hintText: "在此搜索",
            isDense: false,
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
            ),
          ),
          onChanged: (String text) => setState(() {
            c.search.value = text;
          }),
          onFieldSubmitted: (value) => c.searchBook(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: EasyRefresh(
        footer: ClassicFooter(
          dragText: '上拉请求更多'.tr,
          readyText: '正在加载......'.tr,
          processingText: '正在加载......'.tr,
          processedText: '请求成功'.tr,
          noMoreText: '数据没有更多'.tr,
          failedText: '数据获取失败更多'.tr,
          infiniteOffset: null,
        ),
        onLoad: () async {
          await c.searchBook();
        },
        child: Obx(
          () => c.searchList.isNotEmpty
              ? ListView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) => GestureDetector(
                    child: BookInfoCard(toUse: c.searchList[index]),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => BookDetailCard(
                        toUse: c.searchList[index],
                      ),
                    ),
                  ),
                  itemCount: c.searchList.length,
                )
              : c.isSearching.value
                  ? const Center(child: CircularProgressIndicator())
                  : c.search.value.isNotEmpty
                      ? const Center(child: Text("没有结果"))
                      : const Center(
                          child: Text("请在上面的搜索框中搜索"),
                        ),
        ),
      ),
    );
  }
}
