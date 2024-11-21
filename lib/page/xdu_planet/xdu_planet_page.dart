// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Mainpage of XDU Planet.
// Idea from xenode.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
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

  String selected = "xdu_planet.all";
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
    return FutureBuilder<XDUPlanetDatabase>(
      future: repoList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          try {
            List<Article> articles = snapshot.data!.author
                .where(
                  (e) => selected == "xdu_planet.all" || e.name == selected,
                )
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

            Widget chooseChip(String e) => TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: selected == e
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                  ),
                  //selected: selected == e,
                  onPressed: () {
                    setState(() => selected = e);
                  },
                  child: Text(
                    FlutterI18n.translate(context, e),
                    style: TextStyle(
                      color: selected == e
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ).padding(
                  vertical: 0,
                  horizontal: 4,
                );

            return Scaffold(
              appBar: AppBar(
                title: [
                  chooseChip("xdu_planet.all"),
                  const VerticalDivider().padding(vertical: 8),
                  snapshot.data!.author
                      .map((e) => e.name)
                      .map((e) => chooseChip(e))
                      .toList()
                      .toRow()
                      .scrollable(scrollDirection: Axis.horizontal)
                      .expanded(),
                ].toRow().constrained(maxHeight: kToolbarHeight),
              ),
              body: DataList(
                list: articles,
                initFormula: (article) => ArticleCard(
                  article: article,
                ),
              ),
            );
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
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator().padding(bottom: 16),
              Text(FlutterI18n.translate(context, "xdu_planet.loading")),
            ],
          ));
        }
      },
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
      TagsBoxes(
          text: article.author ??
              FlutterI18n.translate(
                context,
                "xdu_planet.unknown_author",
              )),
      Text(
        article.title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      Flex(
        direction: Axis.horizontal,
        children: [
          InformationWithIcon(
            icon: Icons.calendar_month,
            text: article.articleTime.format(pattern: "yyyy-MM-dd"),
          ).flexible(),
          InformationWithIcon(
            icon: Icons.access_time,
            text: article.articleTime.format(pattern: "HH:mm:ss"),
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
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
