/*
Person page of XDU Planet.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/xdu_planet/content_page.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class PersonalPage extends StatefulWidget {
  final String index;
  final Repo data;

  const PersonalPage({
    super.key,
    required this.index,
    required this.data,
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
        title: Text(widget.data.name),
      ),
      body: FutureBuilder<TitleList>(
        future: titleList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              return ListView.builder(
                itemCount: snapshot.data!.list.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    snapshot.data!.list[index].title,
                  ),
                  subtitle: Text(
                    snapshot.data!.list[index].time.toString(),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ContentPage(
                        name: widget.index,
                        index: index,
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
