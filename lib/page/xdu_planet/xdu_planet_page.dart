// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Mainpage of XDU Planet.

import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
                  "本服务提供商是西电开源社区的 Planet 服务，查看我们学校同学们的博客。",
                ),
                actions: [
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
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: sheetMaxWidth - 16,
                    minWidth: min(
                      MediaQuery.of(context).size.width,
                      sheetMaxWidth - 16,
                    ),
                  ),
                  child: () {
                    var articles = snapshot.data!.author
                        .where((e)=> selected == "全部" || e.name == selected)
                        .map((e) => e.article
                            .map((f) => Article(
                                title: f.title,
                                time: f.time,
                                content: f.content,
                                url: f.url,
                                author: e.name))
                            .toList())
                        .reduce((a, b) => a + b);
                    articles.sort((a, b) => b.time.compareTo(a.time));
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: () {
                              var res = snapshot.data!.author
                                  .map((e) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: selected == e.name
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selected = e.name;
                                          });
                                        },
                                        child: Text(
                                          e.name,
                                          style: TextStyle(
                                              color: selected == e.name
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSecondaryContainer),
                                        ),
                                      )))
                                  .toList();
                              res.insert(
                                  0,
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: selected == "全部"
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selected = "全部";
                                          });
                                        },
                                        child: Text(
                                          "全部",
                                          style: TextStyle(
                                              color: selected == "全部"
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSecondaryContainer),
                                        ),
                                      )));
                              return res;
                            }(),
                          ),
                        ),
                        Expanded(
                            child: ListView.builder(
                                itemCount: articles.length ?? 0,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                      title: Text(articles[index].title),
                                      subtitle: Text(
                                          "${articles[index].author} ${articles[index].time}"),
                                      onTap: () {
                                        context.pushReplacement(ContentPage(
                                            article: articles[index],
                                            author: articles[index].author!));
                                      });
                                }))
                      ],
                    );
                  }(),
                ),
              );
            } catch (e) {
              return ReloadWidget(
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
