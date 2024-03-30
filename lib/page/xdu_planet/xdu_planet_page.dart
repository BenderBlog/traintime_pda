// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Mainpage of XDU Planet.

import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/xdu_planet/person_page.dart';
import 'package:watermeter/page/public_widget/split_view.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class XDUPlanetPage extends StatefulWidget {
  const XDUPlanetPage({super.key});

  @override
  State<XDUPlanetPage> createState() => _XDUPlanetPageState();
}

class _XDUPlanetPageState extends State<XDUPlanetPage>
    with AutomaticKeepAliveClientMixin {
  late Future<XDUPlanetDatabase> repoList;

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
              // Map<String, Repo> data = snapshot.data!.repos;
              // List<String> keys = data.keys.toList();
              /*
              Widget icon(int index) => CachedNetworkImage(
                    imageUrl: data[keys[index]]!.favicon,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.rss_feed),
                    width: 32,
                    height: 32,
                  );
              */
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: sheetMaxWidth - 16,
                    minWidth: min(
                      MediaQuery.of(context).size.width,
                      sheetMaxWidth - 16,
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: snapshot.data?.author.length ?? 0,
                    itemBuilder: (context, index) => ListTile(
                      //leading: icon(index),
                      title: Text(snapshot.data!.author[index].name),
                      //subtitle: Text(snapshot.data!.author[index].description),
                      onTap: () => SplitView.of(context).setSecondary(
                        SplitView.material(
                          breakpoint: 360,
                          placeholder: Scaffold(
                            body: const Text("请点进去一个文章").center(),
                          ),
                          child: PersonalPage(
                            person: snapshot.data!.author[index],
                            //index: keys[index],
                            //repo: data[keys[index]]!,
                          ),
                        ),
                      ),
                    ),
                  ),
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
