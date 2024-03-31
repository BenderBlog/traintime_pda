// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Person page of XDU Planet.

import 'dart:io';
import 'dart:math';

import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/xdu_planet/content_page.dart';

class PersonalPage extends StatelessWidget {
  final Person person;

  const PersonalPage({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => launchUrlString(
              person.uri,
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
            itemCount: person.article.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                person.article[index].title,
              ),
              subtitle: Text(
                "发布于：${Jiffy.parseFromDateTime(
                  person.article[index].time,
                ).format(pattern: "yyyy年MM月dd日")}",
              ),
              onTap: () => context.pushReplacement(
                ContentPage(
                  article: person.article[index],
                  author: person.name,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
