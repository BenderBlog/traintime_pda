// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter/material.dart';
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
        title: const Text("工作详情"),
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
                      job.tags.length,
                      (i) => TagsBoxes(
                        text: job.tags[i],
                        backgroundColor: Colors.grey.shade300,
                        textColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MarkdownBody(data: '''

招募 ${job.exceptNumber} 人 · ${job.project.name}

截止 ${Jiffy.parseFromDateTime(job.endTime).format(pattern: "yyyy 年 MM 月 dd 日")}

*如果用户感兴趣，请按右上角的按钮在浏览器中打开*

## 岗位描述

${job.description}

## 工作回报

${job.reward}

## 项目进度

${job.progress.isEmpty ? "信息" : job.progress}
'''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
