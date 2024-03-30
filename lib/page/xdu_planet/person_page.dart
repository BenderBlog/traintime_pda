// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Person page of XDU Planet.

import 'dart:math';

import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/xdu_planet/content_page.dart';
import 'package:watermeter/page/public_widget/split_view.dart';
//import 'package:watermeter/page/xdu_planet/content_page.dart';
//import 'package:watermeter/repository/xdu_planet_session.dart';

class PersonalPage extends StatefulWidget {
  final Person person;
  //final String index;
  //final Repo repo;

  const PersonalPage({
    super.key,
    required this.person,
    //required this.index,
    //required this.repo,
  });

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  /*
  late Future<TitleList> titleList;
  @override
  void initState() {
    super.initState();
    titleList = PlanetSession().titleList(widget.index);
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => launchUrlString(
              widget.person.uri,
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: sheetMaxWidth - 16,
            minWidth: min(
              MediaQuery.of(context).size.width,
              sheetMaxWidth - 16,
            ),
          ),
          child: ListView.builder(
            itemCount: widget.person.article.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                widget.person.article[index].title,
              ),
              subtitle: Text(
                "发布于：${Jiffy.parseFromDateTime(widget.person.article[index].time).format(pattern: "yyyy年MM月dd日")}",
              ),
              onTap: () => SplitView.of(context).setSecondary(
                ContentPage(
                  article: widget.person.article[index],
                  author: widget.person.name,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
