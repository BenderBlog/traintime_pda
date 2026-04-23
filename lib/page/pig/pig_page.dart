// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Pig page — random pig image from pighub.top.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/repository/pighub_session.dart';

class PigPage extends StatefulWidget {
  const PigPage({super.key});

  @override
  State<PigPage> createState() => _PigPageState();
}

class _PigPageState extends State<PigPage> with AutomaticKeepAliveClientMixin {
  late Future<PigHubImage> _future;

  @override
  void initState() {
    super.initState();
    _future = getRandomPig();
  }

  void _fetch() {
    setState(() {
      _future = getRandomPig();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "homepage.dashboard")),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_outlined),
            onPressed: _fetch,
          ),
        ],
      ),
      body: FutureBuilder<PigHubImage>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return [
                  Text(
                    FlutterI18n.translate(context, "new_homepage_hint"),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "Failed to fetch a pig :(\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _fetch,
                    icon: const Icon(Icons.replay_outlined),
                    label: const Text("Try Again"),
                  ),
                ]
                .toColumn(mainAxisAlignment: MainAxisAlignment.center)
                .padding(horizontal: 24)
                .center();
          }

          final image = snapshot.data!;
          return [
                Text(
                  FlutterI18n.translate(context, "new_homepage_hint"),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: Image.network(
                    image.url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 80),
                    ),
                  ),
                ).clipRRect(all: 12),
                const SizedBox(height: 8),
                Text(
                  image.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _fetch,
                  icon: const Icon(Icons.shuffle),
                  label: const Text("Change A Pig"),
                ),
                OutlinedButton.icon(
                  onPressed: () => launchUrlString(
                    image.url,
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Save this Pig"),
                ),
                const SizedBox(height: 16),
              ]
              .toColumn(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              )
              .scrollable()
              .center()
              .padding(horizontal: 24);
        },
      ),
    );
  }
}
