// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Mainpage of XDU Planet.

import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/xdu_planet/content_page.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class XDUPlanetPage extends StatefulWidget {
  const XDUPlanetPage({super.key});

  @override
  State<XDUPlanetPage> createState() => _XDUPlanetPageState();
}

class _XDUPlanetPageState extends State<XDUPlanetPage>
    with AutomaticKeepAliveClientMixin {
  late Future<XDUPlanetDatabase> repoList;
  String selected = "全部";
  bool isAll = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    repoList = PlanetSession().repoList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("XDU Planet"),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("XDU Planet 介绍"),
                content: const Text(
                  "服务提供者是西电开源社区，用于查看我们学校同学们的博客。\n"
                  "觉得有趣/有用的话，欢迎点点star哦\n\n"
                  "<(=ω=)>",
                ),
                actions: [
                  TextButton(
                    child: const Text("项目首页"),
                    onPressed: () => launchUrlString(
                      "https://github.com/xdlinux/planet",
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  TextButton(
                    child: const Text("网页版"),
                    onPressed: () => launchUrlString(
                      "https://xdlinux.github.io/planet/",
                      mode: LaunchMode.externalApplication,
                    ),
                  )
                ],
              ),
            ),
            icon: const Icon(Icons.info),
          )
        ],
      ),
      body: FutureBuilder<XDUPlanetDatabase>(
        future: repoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              List<Article> articles = snapshot.data!.author
                  .where((e) => selected == "全部" || e.name == selected)
                  .map((e) => e.article
                      .map((f) => Article(
                          title: f.title,
                          time: f.time,
                          content: f.content,
                          url: f.url,
                          author: e.name))
                      .toList())
                  .reduce((a, b) => a + b)
                ..sort(
                  (a, b) => b.time.compareTo(a.time),
                );

              Widget chooseChip(String e) => ChoiceChip(
                    label: Text(e),
                    selected: selected == e,
                    onSelected: (bool newValue) {
                      setState(() {
                        selected = e;
                      });
                    },
                  );

              return [
                ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.5,
                  ),
                  children: [
                    "全部",
                    ...snapshot.data!.author.map((e) => e.name),
                  ]
                      .map(
                        (e) => chooseChip(e).padding(
                          vertical: 0,
                          horizontal: 4,
                        ),
                      )
                      .toList(),
                ).constrained(maxHeight: 52),
                DataList(
                  list: articles,
                  initFormula: (article) => ArticleCard(
                    article: article,
                  ),
                ).expanded(),
              ]
                  .toColumn()
                  .constrained(
                    maxWidth: sheetMaxWidth - 16,
                    minWidth: min(
                      MediaQuery.of(context).size.width,
                      sheetMaxWidth - 16,
                    ),
                  )
                  .center();
            } catch (e) {
              return ReloadWidget(
                errorStatus: e,
                function: () {
                  setState(() {
                    repoList = PlanetSession().repoList();
                  });
                },
              );
            }
          } else {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('加载中，请稍等 <(=ω=)>'),
              ],
            ));
          }
        },
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;
  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return [
      TagsBoxes(text: article.author ?? "未知作者"),
      Text(
        article.title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      Flex(
        direction: Axis.horizontal,
        children: [
          informationWithIcon(
            Icons.calendar_month,
            Jiffy.parseFromDateTime(
              article.time,
            ).format(pattern: "yyyy年MM月dd日"),
            context,
          ).flexible(),
          informationWithIcon(
            Icons.access_time,
            Jiffy.parseFromDateTime(
              article.time,
            ).format(pattern: "HH:mm:ss"),
            context,
          ).flexible(),
        ],
      )
    ]
        .toColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
        )
        .padding(
          vertical: 12,
          horizontal: 14,
        )
        .card(
          elevation: 0,
          color: Theme.of(context).colorScheme.secondaryContainer,
        )
        .gestures(
      onTap: () {
        context.pushReplacement(ContentPage(
          article: article,
          author: article.author!,
        ));
      },
    );
  }
}
