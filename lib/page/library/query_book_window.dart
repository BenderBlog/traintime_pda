// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/library/book_detail_card.dart';
import 'package:watermeter/page/library/book_info_card.dart';

class QueryBookWindow extends StatefulWidget {
  final BoxConstraints constraints;
  const QueryBookWindow({super.key, required this.constraints});

  @override
  State<QueryBookWindow> createState() => _QueryBookWindowState();
}

class _QueryBookWindowState extends State<QueryBookWindow>
    with AutomaticKeepAliveClientMixin {
  final LibraryController c = Get.put(LibraryController());

  int get crossItems => widget.constraints.minWidth ~/ 360;

  int rowItem(int length) {
    int rowItem = length ~/ crossItems;
    if (crossItems * rowItem < length) {
      rowItem += 1;
    }
    return rowItem;
  }

  @override
  bool get wantKeepAlive => true;

  late EasyRefreshController _controller;
  late TextEditingController text;

  @override
  void initState() {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: TextFormField(
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
        ).padding(
          vertical: 10,
          horizontal: 8,
        ),
        Expanded(
          child: EasyRefresh(
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
            child: Obx(() {
              if (c.searchList.isNotEmpty) {
                List<Widget> bookList = List<Widget>.generate(
                  c.searchList.length,
                  (index) => GestureDetector(
                    child: BookInfoCard(toUse: c.searchList[index]),
                    onTap: () => BothSideSheet.show(
                      context: context,
                      title: "书籍详细信息",
                      child: BookDetailCard(
                        toUse: c.searchList[index],
                      ),
                    ),
                  ),
                );
                return AlignedGridView.count(
                  shrinkWrap: true,
                  itemCount: bookList.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  crossAxisCount: MediaQuery.sizeOf(context).width ~/ 360,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) => bookList[index],
                );
              } else if (c.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (c.search.value.isNotEmpty) {
                return const Center(child: Text("没有结果"));
              } else {
                return const Center(
                  child: Text("请在上面的搜索框中搜索"),
                );
              }
            }),
          ),
        )
      ],
    ));
  }
}
