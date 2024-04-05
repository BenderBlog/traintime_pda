// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:watermeter/model/lost_and_found.dart';
import 'package:watermeter/model/xidian_ids/creative.dart';
import 'package:watermeter/page/lost_and_found/lost_and_found_card.dart';
import 'package:watermeter/page/public_widget/column_choose_dialog.dart';
import 'package:watermeter/repository/lost_and_found_session.dart';

class LostAndFoundPage extends StatefulWidget {
  const LostAndFoundPage({super.key});

  @override
  State<LostAndFoundPage> createState() => _LostAndFoundPageState();
}

class _LostAndFoundPageState extends State<LostAndFoundPage> {
  TextEditingController text = TextEditingController.fromValue(
    const TextEditingValue(text: ""),
  );
  late Future<List<LostAndFoundInfo>> data;

  static const List<String> choiceList = ["全部", "只看丢失", "只看寻找"];

  List<String> get categories => skill.keys.toList();

  int page = 0;
  int type = 0; // 1->lost; 2->found; ""->all
  bool isEnd = false;

  String getType() {
    if ([1, 2].contains(type)) {
      return type.toString();
    } else {
      return "";
    }
  }

  RxList<LostAndFoundInfo> infos = <LostAndFoundInfo>[].obs;
  RxBool isSearching = false.obs;

  String searchParameter = "";

  Future<void> search({required bool isChanged}) async {
    if (isChanged) {
      infos.clear();
      page = 0;
      isEnd = false;
    } else if (isEnd) {
      return;
    }
    isSearching.value = true;

    page += 1;

    List<LostAndFoundInfo> getData = await LostAndFoundSession().getList(
      page: page,
      type: getType(),
      keyword: text.text,
    );
    if (getData.isNotEmpty) {
      infos.addAll(getData);
    } else {
      isEnd = true;
    }

    isSearching.value = false;
  }

  @override
  void initState() {
    super.initState();
    search(isChanged: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextField(
                  controller: text,
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    hintText: "搜索",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (String text) {
                    setState(() {
                      searchParameter = text;
                      search(isChanged: true);
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: () async {
                  bool isChanged = false;
                  await showDialog<int>(
                    context: context,
                    builder: (context) => ColumnChooseDialog(
                      chooseList: ["全部", "只看丢失", "只看寻找"].toList(),
                    ),
                  ).then((value) {
                    if (value != null) {
                      type = value;
                      isChanged = true;
                    }
                  });
                  if (mounted && isChanged) {
                    setState(() {
                      search(isChanged: true);
                    });
                  }
                },
                child: Text(choiceList[type]),
              ),
            ),
          ],
        ),
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
          await search(isChanged: false);
        },
        child: Obx(
          () => infos.isNotEmpty
              ? AlignedGridView.extent(
                  itemCount: infos.length,
                  itemBuilder: (context, index) =>
                      LostAndFoundCard(toUse: infos[index]),
                  maxCrossAxisExtent: 480,
                )
              : isSearching.value
                  ? const Center(child: CircularProgressIndicator())
                  : infos.isNotEmpty
                      ? const Center(child: Text("没有结果"))
                      : const Center(
                          child: Text("请在上面的搜索框中搜索"),
                        ),
        ),
      ),
    );
  }
}
