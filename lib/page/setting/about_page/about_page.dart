// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/page/public_widget/app_icon.dart';
import 'package:watermeter/page/setting/about_page/film_component.dart';
import 'package:watermeter/model/about_page.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool devVisible = false;
  bool eggVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "setting.about_page.title")),
      ),
      body: ListView(
        children: [
          [
                const AppIconWidget(size: 64),
                const VerticalDivider(color: Colors.transparent),
                DefaultTextStyle.merge(
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 22),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              Platform.isIOS ||
                                  Platform.isMacOS ||
                                  Platform.isAndroid
                              ? "XDYou"
                              : "Traintime PDA",
                        ),
                        TextSpan(text: " v${preference.packageInfo.version}\n"),
                        TextSpan(
                          text: "Lucky Star Edition",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
              .toRow(crossAxisAlignment: CrossAxisAlignment.center)
              .padding(all: 16),
          ...linkData.map(
            (e) => ListTile(
              leading: Icon(e.icon),
              title: Text(FlutterI18n.translate(context, e.nameKey)),
              onTap: () => launchUrl(
                Uri.parse(e.url),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.balance),
            title: Text(
              FlutterI18n.translate(context, "setting.about_page.know_more"),
            ),
            onTap: () => showLicensePage(
              context: context,
              applicationName:
                  Platform.isIOS || Platform.isMacOS || Platform.isAndroid
                  ? "XDYou"
                  : "Traintime PDA",
              applicationVersion:
                  "v${preference.packageInfo.version}+"
                  "${preference.packageInfo.buildNumber}",
              applicationIcon: const AppIconWidget().padding(vertical: 16),
              applicationLegalese: FlutterI18n.translate(
                context,
                "setting.about_page.copyright_notice",
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(
              FlutterI18n.translate(context, "setting.about_page.beian"),
            ),
            subtitle: const Text("陕ICP备2024026116号-1A"),
          ),
          if (Platform.isAndroid)
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.about_page.sign_android",
                ),
              ),
              subtitle: Text(preference.packageInfo.buildSignature),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              FlutterI18n.translate(
                context,
                "setting.acknowledgement",
                translationParams: {
                  "developers": getDevelopers.length.toString(),
                },
              ),
            ),
            onTap: () => setState(() {
              devVisible = !devVisible;
            }),
            trailing: Icon(
              devVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),
          if (devVisible)
            ...getDevelopers.map(
              (developer) => ListTile(
                leading: CachedNetworkImage(
                  fit: BoxFit.fitHeight,
                  imageUrl: developer.imageUrl,
                  errorWidget: (context, _, _) => Icon(Icons.person),
                ).clipOval().constrained(width: 24, height: 24),
                title: Text(developer.name),
                subtitle: Text(
                  FlutterI18n.translate(context, developer.descriptionI18nKey),
                ),
                trailing: Icon(Icons.open_in_new),
                onTap: () => launchUrl(
                  Uri.parse(developer.url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text("Okaerinasaimase, goshujinsama"),
            onTap: () => setState(() {
              eggVisible = !eggVisible;
            }),
            trailing: Icon(
              eggVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),
          if (eggVisible) const FilmComponent(),
        ].map((e) => e.constrained(maxWidth: 800).center()).toList(),
      ),
    );
  }
}
