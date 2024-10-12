// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/creative.dart';
import 'package:watermeter/page/creative_job/creative_job_choice.dart';
import 'package:watermeter/page/creative_job/creative_job_description.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
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
                    hintText: FlutterI18n.translate(
                      context,
                      "creative_job.search_hint",
                    ),
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
                    title: FlutterI18n.translate(
                      context,
                      "creative_job.choice_type",
                    ),
                  );
                  if (mounted) {
                    setState(() {
                      search(isChanged: true);
                    });
                  }
                },
                child: Text(FlutterI18n.translate(
                  context,
                  "creative_job.position_type",
                )),
              ),
            ),
          ],
        ),
      ),
      body: EasyRefresh(
        footer: ClassicFooter(
          dragText: FlutterI18n.translate(
            context,
            "drag_text",
          ),
          readyText: FlutterI18n.translate(
            context,
            "ready_text",
          ),
          processingText: FlutterI18n.translate(
            context,
            "processing_text",
          ),
          processedText: FlutterI18n.translate(
            context,
            "processed_text",
          ),
          noMoreText: FlutterI18n.translate(
            context,
            "no_more_text",
          ),
          failedText: FlutterI18n.translate(
            context,
            "failed_text",
          ),
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
                      ? EmptyListView(
                          text: FlutterI18n.translate(
                          context,
                          "creative_job.no_result",
                        ))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 96,
                            ),
                            const Divider(color: Colors.transparent),
                            Text(FlutterI18n.translate(
                              context,
                              "creative_job.please_search",
                            )),
                          ],
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
              Text(FlutterI18n.translate(
                context,
                "creative_job.query_for_person",
                translationParams: {
                  "exceptNumber": job.exceptNumber.toString(),
                },
              )),
              Text(
                "${job.project.name} · ",
              ),
              Text(FlutterI18n.translate(
                context,
                "creative_job.end_time",
                translationParams: {
                  /// TODO: change it to locale...
                  "endTime": Jiffy.parseFromDateTime(job.endTime)
                      .format(pattern: "yyyy 年 MM 月 dd 日"),
                },
              )),
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
