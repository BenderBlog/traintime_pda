// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:both_side_sheet/both_side_sheet.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/creative.dart';
import 'package:watermeter/page/creative_job/creative_job_choice.dart';
import 'package:watermeter/page/creative_job/creative_job_description.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/xidian_ids/creative_service_session.dart';

class CreativeJobView extends StatefulWidget {
  const CreativeJobView({super.key});

  @override
  State<CreativeJobView> createState() => _CreativeJobViewState();
}

class _CreativeJobViewState extends State<CreativeJobView> {
  TextEditingController text = TextEditingController.fromValue(
    const TextEditingValue(text: ""),
  );
  late Future<List<Job>> data;

  List<String> get categories => skill.keys.toList();

  int page = 0;
  bool isEnd = false;

  RxList<Job> jobs = <Job>[].obs;
  RxBool isSearching = false.obs;

  (String, List<String>)? searchTags;
  String searchParameter = "";

  Future<void> search({required bool isChanged}) async {
    if (isChanged) {
      jobs.clear();
      page = 0;
      isEnd = false;
    } else if (isEnd) {
      return;
    }
    isSearching.value = true;

    page += 1;

    /// where, or, fuzzyWhere, fuzzyOr
    Map query = {
      "order": "created_at desc",
      "size": 10,
      "page": page,
    };

    if (searchParameter.isNotEmpty) {
      query.addAll(
        {
          "fuzzyOr": [
            {"name": searchParameter},
            {"description": searchParameter},
            {"reward": searchParameter}
          ],
        },
      );
    }

    query.addAll(
      {
        "where": [
          {
            if (searchTags != null && searchTags!.$1.isNotEmpty)
              "skill": searchTags?.$1,
            "tags": searchTags?.$2 ?? [],
          }
        ],
      },
    );

    List<Job> getData = await CreativeServiceSession().getJob(
      searchParameter: query,
    );
    if (getData.isNotEmpty) {
      jobs.addAll(getData);
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
                    hintText: "搜索需求",
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
                  searchTags = await BothSideSheet.show<(String, List<String>)>(
                    context: context,
                    child: CategoryChoiceView(
                      data: searchTags ?? ("", []),
                    ),
                    title: "选择种类",
                  );
                  if (mounted) {
                    setState(() {
                      search(isChanged: true);
                    });
                  }
                },
                child: const Text("职位类型"),
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
          () => jobs.isNotEmpty
              ? ListView.separated(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) =>
                      CreativeJobListTile(job: jobs[index]),
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 0),
                )
              : isSearching.value
                  ? const Center(child: CircularProgressIndicator())
                  : jobs.isNotEmpty
                      ? const Center(child: Text("没有结果"))
                      : const Center(
                          child: Text("请在上面的搜索框中搜索"),
                        ),
        ),
      ),
    );
  }
}

class CreativeJobListTile extends StatelessWidget {
  final Job job;
  const CreativeJobListTile({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(job.name),
          TagsBoxes(
            text: job.skill,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2.0),
          Wrap(
            spacing: 8.0,
            children: List.generate(
              job.tags?.length ?? 0,
              (i) => TagsBoxes(
                text: job.tags![i],
                backgroundColor: Colors.grey.shade300,
                textColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4.0,
            children: [
              Text(
                "招募 ${job.exceptNumber} 人 · ",
              ),
              Text(
                "${job.project.name} · ",
              ),
              Text(
                "截止日期 ${Jiffy.parseFromDateTime(job.endTime).format(pattern: "yyyy 年 MM 月 dd 日")}",
              ),
            ],
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreativeJobDescription(job: job),
        ),
      ),
    );
  }
}
