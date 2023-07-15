/*
Person page of XDU Planet.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/xdu_planet/content_page.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class PersonalPage extends StatefulWidget {
  final String index;
  final Repo repo;

  const PersonalPage({
    super.key,
    required this.index,
    required this.repo,
  });

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  late Future<TitleList> titleList;

  @override
  void initState() {
    super.initState();
    titleList = PlanetSession().titleList(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.repo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => launchUrlString(
              widget.repo.website,
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: FutureBuilder<TitleList>(
        future: titleList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              var data = snapshot.data!;
              return ListView.builder(
                itemCount: data.list.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    data.list[index].title,
                  ),
                  subtitle: Text(
                    "发布于：${Jiffy.parseFromDateTime(data.list[index].time).format(pattern: "yyyy年MM月dd日")}",
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ContentPage(
                        feed: widget.index,
                        index: index,
                        authorName: widget.repo.name,
                        title: data.list[index].title,
                        time: Jiffy.parseFromDateTime(data.list[index].time)
                            .format(pattern: "yyyy年MM月dd日"),
                        link: data.list[index].url,
                      ),
                    ),
                  ),
                ),
              );
            } catch (e, s) {
              return Text("Error: $e, $s");
            }
          } else {
            return const Text("Loading...");
          }
        },
      ),
    );
  }
}
