// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Mainpage of XDU Planet.

import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/xdu_planet/person_page.dart';
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
                  "本服务提供本学校同学的博客访问服务，后端基于小可怜网的代码。\n"
                  "小可怜网是为了老电脑访问现代讯息而创建的网站，我扩展了代码，加入了 PDA 可以访问的简易 API。\n"
                  "本服务是为了分享同学之间的学习经验和想法，与服务提供方无关。\n"
                  "如果你的博客能保证内容健康和一定程度的更新，欢迎加入。若有侵权之嫌，联系开发者处理。",
                ),
                actions: [
                  TextButton(
                    child: const Text("小可怜网"),
                    onPressed: () => launchUrlString(
                      "https://andyzhk.azurewebsites.net/clie/",
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  TextButton(
                    child: const Text("网页版"),
                    onPressed: () => launchUrlString(
                      "https://server.superbart.xyz",
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
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PersonalPage(
                          person: snapshot.data!.author[index],
                          //index: keys[index],
                          //repo: data[keys[index]]!,
                        ),
                      )),
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
