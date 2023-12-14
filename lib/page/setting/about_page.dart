// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("关于本软件")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: ListView(
            children: [
              Text(
                "${Platform.isIOS || Platform.isMacOS ? "XDYou" : "Traintime PDA"} v${preference.packageInfo.version} \n"
                "${Platform.isIOS || Platform.isMacOS ? "Iron Man" : "Hanger 18"} Edition",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              )
                  .gestures(
                    onTap: () => Fluttertoast.showToast(
                      msg: Platform.isIOS || Platform.isMacOS
                          ? "Heavy boots of lead fills his victims full of dread, run as fast as they can, IRON MAN LIVES AGAIN!!!"
                          : "This place can't make scene, possibly I have seen to much. Hanger 18, I known too much...",
                    ),
                  )
                  .center(),
              Image.asset(
                "assets/Credit.jpg",
                fit: BoxFit.fitWidth,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton(
                        child: const Text("主页"),
                        onPressed: () => launchUrl(
                          Uri.parse("https://legacy.superbart.xyz/xdyou.html"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      TextButton(
                        child: const Text("代码"),
                        onPressed: () => launchUrl(
                          Uri.parse("https://github.com/BenderBlog/watermeter"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      TextButton(
                        child: const Text("授权协议"),
                        onPressed: () => launchUrl(
                          Uri.parse(
                              "https://legacy.superbart.xyz/xdyou_eula.html"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      TextButton(
                        child: const Text("给我捐款"),
                        onPressed: () => launchUrl(
                          Uri.parse("https://afdian.net/a/benderblog"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      TextButton(
                        child: const Text("电表主页"),
                        onPressed: () => launchUrl(
                          Uri.parse("https://myxdu.moefactory.com/"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      TextButton(
                        child: const Text("xidian-script"),
                        onPressed: () => launchUrl(
                          Uri.parse(
                              "https://github.com/xdlinux/xidian-scripts"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      TextButton(
                        child: const Text("西电目录"),
                        onPressed: () => launchUrl(
                          Uri.parse("https://ncov.hawa130.com/about"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      TextButton(
                        child: const Text("Ray"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Self Portrait"),
                              content: Image.asset("assets/Ray.jpg"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Ciallo~(∠・ω< )⌒☆"),
                                  onPressed: () => launchUrl(
                                    Uri.parse(
                                      "https://www.coolapk.com/feed/45104934",
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
