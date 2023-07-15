/*
Mainpage of XDU Planet.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/xdu_planet/person_page.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class XDUPlanetPage extends StatefulWidget {
  const XDUPlanetPage({super.key});

  @override
  State<XDUPlanetPage> createState() => _XDUPlanetPageState();
}

class _XDUPlanetPageState extends State<XDUPlanetPage>
    with AutomaticKeepAliveClientMixin {
  late Future<RepoList> repoList;

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
      body: FutureBuilder<RepoList>(
        future: repoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              Map<String, Repo> data = snapshot.data!.repos;
              List<String> keys = data.keys.toList();
              Widget icon(int index) => data[keys[index]]!.favicon == ""
                  ? const Icon(
                      Icons.rss_feed,
                      size: 32,
                    )
                  : Image.network(
                      data[keys[index]]!.favicon,
                      width: 32,
                      height: 32,
                    );
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => ListTile(
                  leading: icon(index),
                  title: Text(data[keys[index]]!.name),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PersonalPage(
                      index: keys[index],
                      data: data[keys[index]]!,
                    ),
                  )),
                ),
              );
            } catch (e) {
              return Text("Error: $e");
            }
          } else {
            return const Text("Loading...");
          }
        },
      ),
    );
  }
}
