/*
Mainpage of XDU Planet.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
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
      ),
      body: FutureBuilder<RepoList>(
        future: repoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            try {
              return ListView.builder(
                itemCount: snapshot.data!.repos.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(snapshot.data!.repos[index].name),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        PersonalPage(name: snapshot.data!.repos[index].name),
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
