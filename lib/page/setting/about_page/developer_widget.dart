// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
      onTap: () => launchUrl(
        Uri.parse(developer.url),
        mode: LaunchMode.externalApplication,
      ),
      child: ListTile(
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.zero,
        leading: CachedNetworkImage(
          fit: BoxFit.fitHeight,
          imageUrl: developer.imageUrl,
        ).clipOval().constrained(
              width: 48,
              height: 48,
            ),
        title: Text(developer.name),
        subtitle: Text(developer.description),
      ),
    );
  }
}
