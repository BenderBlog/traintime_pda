// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Link {
  final String name;
  final Icon icon;
  final String url;

  const Link({
    required this.name,
    required this.icon,
    required this.url,
  });
}

class LinkWidget extends StatelessWidget {
  final String name;
  final Icon icon;
  final String url;
  const LinkWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      leading: icon,
      title: Text(name),
      onTap: () => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}
