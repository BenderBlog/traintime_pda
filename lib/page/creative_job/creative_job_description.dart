// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/creative.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CreativeJobDescription extends StatelessWidget {
  final Job job;
  const CreativeJobDescription({
    super.key,
    required this.job,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(
          context,
          "creative_job.job_description",
        )),
        actions: [
          IconButton(
            onPressed: () =>
                launchUrlString("https://scjspt.xidian.edu.cn/job/${job.id}"),
            icon: const Icon(Icons.link),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: sheetMaxWidth - 16,
              minWidth: min(
                MediaQuery.of(context).size.width,
                sheetMaxWidth - 16,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TagsBoxes(
                      text: job.skill,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    ...List.generate(
                      job.tags?.length ?? 0,
                      (i) => TagsBoxes(
                        text: job.tags![i],
                        backgroundColor: Colors.grey.shade300,
                        textColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MarkdownBody(data: '''

${FlutterI18n.translate(context, "creative_job.query_for_person", translationParams: {
                      "exceptNumber": job.exceptNumber.toString()
                    })}${job.project.name}

${FlutterI18n.translate(context, "creative_job.end_time", translationParams: {
                      "endTime": Jiffy.parseFromDateTime(job.endTime)
                          .format(pattern: "yyyy 年 MM 月 dd 日")
                    })}

*${FlutterI18n.translate(context, "creative_job.browser_hint")}*

## ${FlutterI18n.translate(context, "creative_job.job_description_title")}

${job.description.isNotEmpty ? job.description : FlutterI18n.translate(context, "creative_job.no_description")}}

## ${FlutterI18n.translate(context, "creative_job.reward_title")}

${job.reward.isNotEmpty ? job.reward : FlutterI18n.translate(context, "creative_job.no_description")}

## ${FlutterI18n.translate(context, "creative_job.progress_title")}

${job.progress.isEmpty ? FlutterI18n.translate(context, "creative_job.no_description") : job.progress}
'''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
