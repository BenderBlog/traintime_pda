// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

class Developer {
  final String name;
  final String imageUrl;
  final String description;
  final String url;
  const Developer(
    this.name,
    this.imageUrl,
    this.description,
    this.url,
  );
}

class DeveloperWidget extends StatelessWidget {
  final Developer developer;
  const DeveloperWidget({
    super.key,
    required this.developer,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushDialog(AlertDialog(
        title: Text(developer.name),
        content: Text(developer.description.splitMapJoin(
          " / ",
          onMatch: (p0) => "\n",
        )),
        actions: [
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(developer.url),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text("More about this guy"),
          )
        ],
      )),
      child: CachedNetworkImage(
        fit: BoxFit.fitHeight,
        imageUrl: developer.imageUrl,
      ).clipOval().constrained(
            width: 48,
            height: 48,
          ),
    );
  }
}
